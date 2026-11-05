from django.contrib.auth import authenticate, get_user_model
from rest_framework import serializers

from . import models

User = get_user_model()


class SafeImageField(serializers.ImageField):
    """Fayli yo'q rasmlar uchun xato bermasdan `None` qaytaradi."""

    def to_representation(self, value):
        if not value:
            return None
        try:
            return value.url
        except (ValueError, AttributeError):
            return None


class CategorySerializer(serializers.ModelSerializer):
    logo = SafeImageField(read_only=True)
    display_name = serializers.CharField(read_only=True)

    class Meta:
        model = models.Category
        fields = [
            'id',
            'name',
            'name_ru',
            'name_en',
            'display_name',
            'logo',
            'is_active',
        ]


class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    image = SafeImageField(read_only=True)
    final_price = serializers.SerializerMethodField()
    discount_percent = serializers.SerializerMethodField()
    display_name = serializers.CharField(read_only=True)
    display_description = serializers.CharField(read_only=True)

    class Meta:
        model = models.Product
        fields = [
            'id',
            'code',
            'category',
            'image',
            'name',
            'name_ru',
            'name_en',
            'display_name',
            'description',
            'description_ru',
            'description_en',
            'display_description',
            'price',
            'discount_price',
            'discount_status',
            'count',
            'final_price',
            'discount_percent',
            'created_at',
            'updated_at',
        ]

    def get_final_price(self, obj):
        if obj.discount_status and obj.discount_price:
            return obj.discount_price
        return obj.price

    def get_discount_percent(self, obj):
        if obj.discount_status and obj.discount_price and obj.price:
            return round((obj.price - obj.discount_price) / obj.price * 100)
        return 0


class BannerSerializer(serializers.ModelSerializer):
    image = SafeImageField(read_only=True)
    product_1 = ProductSerializer(read_only=True)

    class Meta:
        model = models.Banner
        fields = ['id', 'title', 'image', 'description', 'product_1']


class UserSerializer(serializers.ModelSerializer):
    photo = SafeImageField(required=False, allow_null=True)

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'phone',
            'address',
            'photo',
            'date_joined',
        ]
        read_only_fields = ['id', 'date_joined']

    def validate_username(self, value):
        request = self.context.get('request')
        queryset = User.objects.filter(username=value)
        if request is not None and request.user.is_authenticated:
            queryset = queryset.exclude(pk=request.user.pk)
        if queryset.exists():
            raise serializers.ValidationError("Bu login allaqachon band.")
        return value


class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField(required=False, allow_blank=True)
    phone = serializers.CharField(max_length=150, required=False, allow_blank=True)
    address = serializers.CharField(required=False, allow_blank=True)
    password = serializers.CharField(write_only=True, min_length=6)
    confirm_password = serializers.CharField(write_only=True)

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Bu login allaqachon band.")
        return value

    def validate(self, attrs):
        if attrs.get('password') != attrs.get('confirm_password'):
            raise serializers.ValidationError(
                {'confirm_password': "Parollar bir xil emas."}
            )
        return attrs

    def create(self, validated_data):
        validated_data.pop('confirm_password', None)
        password = validated_data.pop('password')
        return User.objects.create_user(password=password, **validated_data)


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        request = self.context.get('request')
        user = authenticate(
            request=request,
            username=attrs.get('username'),
            password=attrs.get('password'),
        )
        if user is None:
            raise serializers.ValidationError("Login yoki parol noto'g'ri.")
        if not user.is_active:
            raise serializers.ValidationError("Foydalanuvchi faol emas.")
        attrs['user'] = user
        return attrs


class CartProductSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    total_price = serializers.DecimalField(
        max_digits=12, decimal_places=2, read_only=True
    )
    discount_price = serializers.DecimalField(
        max_digits=12, decimal_places=2, read_only=True
    )

    class Meta:
        model = models.CartProduct
        fields = ['id', 'code', 'product', 'count', 'total_price', 'discount_price']


class CartSerializer(serializers.ModelSerializer):
    items = CartProductSerializer(source='cartproduct_set', many=True, read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    cart_total_price = serializers.SerializerMethodField()
    discount_total_price = serializers.SerializerMethodField()
    count_product = serializers.SerializerMethodField()
    total_quantity = serializers.SerializerMethodField()

    class Meta:
        model = models.Cart
        fields = [
            'id',
            'code',
            'status',
            'status_display',
            'date',
            'items',
            'cart_total_price',
            'discount_total_price',
            'count_product',
            'total_quantity',
        ]

    def _items(self, obj):
        return list(obj.cartproduct_set.all())

    def get_cart_total_price(self, obj):
        return sum(
            (item.total_price for item in self._items(obj) if item.product_id),
            0,
        )

    def get_discount_total_price(self, obj):
        return sum(
            (item.discount_price for item in self._items(obj) if item.product_id),
            0,
        )

    def get_count_product(self, obj):
        return len(self._items(obj))

    def get_total_quantity(self, obj):
        return sum(item.count for item in self._items(obj))


class WishListSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)

    class Meta:
        model = models.WishList
        fields = ['id', 'product', 'date']


class CartItemAddSerializer(serializers.Serializer):
    product_code = serializers.SlugRelatedField(
        slug_field='code',
        queryset=models.Product.objects.all(),
        source='product',
    )
    count = serializers.IntegerField(min_value=1, default=1)


class CartItemUpdateSerializer(serializers.Serializer):
    count = serializers.IntegerField(min_value=0)


class CheckoutSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, required=False)
    phone = serializers.CharField(max_length=150, required=False)
    address = serializers.CharField(required=False)
    latitude = serializers.FloatField(
        required=False, allow_null=True, min_value=-90, max_value=90
    )
    longitude = serializers.FloatField(
        required=False, allow_null=True, min_value=-180, max_value=180
    )

    def validate_username(self, value):
        request = self.context.get('request')
        queryset = User.objects.filter(username=value)
        if request is not None and request.user.is_authenticated:
            queryset = queryset.exclude(pk=request.user.pk)
        if queryset.exists():
            raise serializers.ValidationError("Bu login allaqachon band.")
        return value

    def validate(self, attrs):
        latitude = attrs.get('latitude')
        longitude = attrs.get('longitude')
        if (latitude is None) != (longitude is None):
            raise serializers.ValidationError(
                "Latitude va longitude birgalikda yuborilishi kerak."
            )
        return attrs
