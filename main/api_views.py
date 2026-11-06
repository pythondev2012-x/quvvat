from django.db import transaction
from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.urls import reverse
from rest_framework import generics, permissions, status
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.views import APIView

from . import models, serializers
from .selectors import grouped_products
from .tasks import queue_order_notification


def get_active_cart(user):
    cart = models.Cart.objects.filter(user=user, status=1).first()
    if cart is None:
        cart = models.Cart.objects.create(user=user, status=1)
    return cart


def load_cart(cart_id):
    return (
        models.Cart.objects.prefetch_related('cartproduct_set__product__category')
        .filter(pk=cart_id)
        .first()
    )


def cart_response(request, cart, status_code=status.HTTP_200_OK):
    cart = load_cart(cart.pk) or cart
    return Response(
        serializers.CartSerializer(cart, context={'request': request}).data,
        status=status_code,
    )


def add_product_to_cart(cart, product, count):
    """Savatda bir xil mahsulot bo'lsa sonini qo'shadi, dublikatlarni birlashtiradi."""
    items = list(
        models.CartProduct.objects.filter(cart=cart, product=product).order_by('pk')
    )
    if not items:
        models.CartProduct.objects.create(cart=cart, product=product, count=count)
        return True

    item = items[0]
    extra = sum(other.count for other in items[1:])
    item.count += count + extra
    item.save(update_fields=['count'])
    if len(items) > 1:
        models.CartProduct.objects.filter(
            pk__in=[other.pk for other in items[1:]]
        ).delete()
    return False


class ApiRootView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response(
            {
                'products': request.build_absolute_uri(reverse('api-products')),
                'product_sections': request.build_absolute_uri(
                    reverse('api-product-sections')
                ),
                'categories': request.build_absolute_uri(reverse('api-categories')),
                'banners': request.build_absolute_uri(reverse('api-banners')),
                'register': request.build_absolute_uri(reverse('api-register')),
                'login': request.build_absolute_uri(reverse('api-login')),
                'profile': request.build_absolute_uri(reverse('api-me')),
                'wishlist': request.build_absolute_uri(reverse('api-wishlist')),
                'cart': request.build_absolute_uri(reverse('api-cart')),
                'orders': request.build_absolute_uri(reverse('api-orders')),
                'checkout': request.build_absolute_uri(reverse('api-checkout')),
            }
        )


class CategoryListView(generics.ListAPIView):
    serializer_class = serializers.CategorySerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = models.Category.objects.all().order_by('name')
        active = self.request.query_params.get('active')
        if active in ('1', 'true', 'yes'):
            queryset = queryset.filter(is_active=True)
        return queryset


class CategoryDetailView(generics.RetrieveAPIView):
    serializer_class = serializers.CategorySerializer
    permission_classes = [permissions.AllowAny]
    queryset = models.Category.objects.all()


class ProductListView(generics.ListAPIView):
    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = models.Product.objects.select_related('category').order_by(
            '-created_at'
        )
        params = self.request.query_params

        q = params.get('q', '').strip()
        if q:
            queryset = queryset.filter(
                Q(name__icontains=q)
                | Q(name_ru__icontains=q)
                | Q(name_en__icontains=q)
                | Q(description__icontains=q)
                | Q(description_ru__icontains=q)
                | Q(description_en__icontains=q)
                | Q(category__name__icontains=q)
                | Q(category__name_ru__icontains=q)
                | Q(category__name_en__icontains=q)
            )

        category = params.get('category')
        if category:
            if category.isdigit():
                queryset = queryset.filter(category_id=category)
            else:
                queryset = queryset.filter(
                    Q(category__name__iexact=category)
                    | Q(category__name_ru__iexact=category)
                    | Q(category__name_en__iexact=category)
                )

        for key, lookup in (('min_price', 'price__gte'), ('max_price', 'price__lte')):
            value = params.get(key)
            if value:
                try:
                    queryset = queryset.filter(**{lookup: float(value)})
                except (TypeError, ValueError):
                    pass

        if params.get('discount') in ('1', 'true', 'yes'):
            queryset = queryset.filter(discount_status=True)
        if params.get('in_stock') in ('1', 'true', 'yes'):
            queryset = queryset.filter(count__gt=0)

        ordering = params.get('ordering')
        allowed_ordering = {
            'price',
            '-price',
            'name',
            '-name',
            'count',
            '-count',
            'created_at',
            '-created_at',
        }
        if ordering in allowed_ordering:
            queryset = queryset.order_by(ordering)

        return queryset


class ProductDetailView(generics.RetrieveAPIView):
    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.AllowAny]
    lookup_field = 'code'
    queryset = models.Product.objects.select_related('category')


class ProductSectionsView(APIView):
    """Mahsulotlarni kategoriya bo'yicha bo'limlarga guruhlab qaytaradi."""

    permission_classes = [permissions.AllowAny]

    def get(self, request):
        results = []
        for section in grouped_products(limit=8):
            results.append(
                {
                    'category': serializers.CategorySerializer(
                        section['category']
                    ).data,
                    'products': serializers.ProductSerializer(
                        section['products'],
                        many=True,
                        context={'request': request},
                    ).data,
                }
            )
        return Response({'count': len(results), 'results': results})


class BannerListView(generics.ListAPIView):
    serializer_class = serializers.BannerSerializer
    permission_classes = [permissions.AllowAny]
    queryset = models.Banner.objects.select_related('product_1__category').order_by(
        'id'
    )


class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = serializers.RegisterSerializer(
            data=request.data, context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response(
            {
                'token': token.key,
                'user': serializers.UserSerializer(
                    user, context={'request': request}
                ).data,
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = serializers.LoginSerializer(
            data=request.data, context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, _ = Token.objects.get_or_create(user=user)
        return Response(
            {
                'token': token.key,
                'user': serializers.UserSerializer(
                    user, context={'request': request}
                ).data,
            }
        )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        Token.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = serializers.UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class WishlistListView(generics.ListAPIView):
    serializer_class = serializers.WishListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            models.WishList.objects.filter(user=self.request.user)
            .select_related('product__category')
            .order_by('-date')
        )


class WishlistItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, product_code):
        product = get_object_or_404(models.Product, code=product_code)
        item, created = models.WishList.objects.get_or_create(
            user=request.user, product=product
        )
        return Response(
            serializers.WishListSerializer(item, context={'request': request}).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    def delete(self, request, product_code):
        deleted, _ = models.WishList.objects.filter(
            user=request.user, product__code=product_code
        ).delete()
        if not deleted:
            return Response(
                {'detail': "Saqlanganlar ro'yxatida bunday mahsulot yo'q."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(status=status.HTTP_204_NO_CONTENT)


class CartView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        cart = get_active_cart(request.user)
        return cart_response(request, cart)

    def delete(self, request):
        cart = get_active_cart(request.user)
        cart.cartproduct_set.all().delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class CartItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = serializers.CartItemAddSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        product = serializer.validated_data['product']
        count = serializer.validated_data['count']

        cart = get_active_cart(request.user)
        created = add_product_to_cart(cart, product, count)
        return cart_response(
            request,
            cart,
            status_code=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class CartItemDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get_item(self, request, cartproduct_code):
        return get_object_or_404(
            models.CartProduct,
            code=cartproduct_code,
            cart__user=request.user,
            cart__status=1,
        )

    def patch(self, request, cartproduct_code):
        item = self._get_item(request, cartproduct_code)
        serializer = serializers.CartItemUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        count = serializer.validated_data['count']
        cart = item.cart
        if count == 0:
            item.delete()
        else:
            item.count = count
            item.save(update_fields=['count'])
        return cart_response(request, cart)

    def delete(self, request, cartproduct_code):
        item = self._get_item(request, cartproduct_code)
        cart = item.cart
        item.delete()
        return cart_response(request, cart)


class OrderListView(generics.ListAPIView):
    serializer_class = serializers.CartSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            models.Cart.objects.filter(user=self.request.user)
            .exclude(status=1)
            .prefetch_related('cartproduct_set__product__category')
            .order_by('-date')
        )


class OrderDetailView(generics.RetrieveAPIView):
    serializer_class = serializers.CartSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'code'

    def get_queryset(self):
        return (
            models.Cart.objects.filter(user=self.request.user)
            .exclude(status=1)
            .prefetch_related('cartproduct_set__product__category')
        )


class CheckoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = serializers.CheckoutSerializer(
            data=request.data, context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        cart = models.Cart.objects.filter(user=request.user, status=1).first()
        if cart is None:
            return Response(
                {'detail': "Faol savat topilmadi."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        items = list(
            models.CartProduct.objects.filter(cart=cart).select_related('product')
        )
        if not items:
            return Response(
                {'detail': "Savat bo'sh."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        latitude = data.get('latitude')
        longitude = data.get('longitude')
        item_ids = [item.pk for item in items]
        user = request.user
        updated_fields = []

        for field in ('username', 'phone', 'address'):
            if field in data:
                setattr(user, field, data[field])
                updated_fields.append(field)

        with transaction.atomic():
            if updated_fields:
                user.save(update_fields=updated_fields)

            for item in items:
                if item.product_id:
                    item.product.count = max(0, item.product.count - item.count)
                    item.product.save(update_fields=['count'])

            cart.status = 2
            cart.save(update_fields=['status'])

            transaction.on_commit(
                lambda: queue_order_notification(
                    cart.pk, item_ids, latitude=latitude, longitude=longitude
                ),
                robust=True,
            )

        return cart_response(request, cart, status_code=status.HTTP_201_CREATED)
