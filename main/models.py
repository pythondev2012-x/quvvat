from django.db import models, transaction
from django.db.models.signals import post_delete
from django.dispatch import receiver
from uuid import uuid4

from django.contrib.auth.models import AbstractUser
from django.contrib.auth import get_user_model

from .translation import localized_field


class User(AbstractUser):
    phone = models.CharField(max_length=150, null= True, blank=True)
    address = models.TextField(null=True, blank=True)
    photo = models.ImageField(upload_to='users', null=True, blank=True)


    class Meta(AbstractUser.Meta):
        swappable = "AUTH_USER_MODEL"




class Code(models.Model):
    code = models.CharField(max_length=150, unique=True, default=uuid4, blank=True, null=True)


    def __str__(self):
        return self.code

    class Meta:
        abstract = True

class Category(models.Model):
    logo = models.ImageField(upload_to='categories')
    name = models.CharField(max_length=150)
    name_ru = models.CharField(max_length=150, blank=True, default='')
    name_en = models.CharField(max_length=150, blank=True, default='')
    is_active = models.BooleanField(default=False,null=True,blank=True)

    @property
    def display_name(self):
        return localized_field(self, 'name')

    def __str__(self):
        return self.name



class Product(Code):
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='products')
    name = models.CharField(max_length=150)
    name_ru = models.CharField(max_length=150, blank=True, default='')
    name_en = models.CharField(max_length=150, blank=True, default='')
    description = models.TextField()
    description_ru = models.TextField(blank=True, default='')
    description_en = models.TextField(blank=True, default='')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    discount_status = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    count = models.BigIntegerField(default=0)

    @property
    def display_name(self):
        return localized_field(self, 'name')

    @property
    def display_description(self):
        return localized_field(self, 'description')

    def __str__(self):
        return self.name



class Banner(models.Model):
    title = models.CharField(max_length=150)
    image = models.ImageField(upload_to='banners')
    description = models.TextField()
    product_1 = models.ForeignKey(Product, on_delete=models.SET_NULL , null=True, blank=True)



CART_STATUS = (
    (1, 'No Faol'),
    (2, "Yig'ilmoqda"),
    (3, "Yo'lda"),
    (4, "Yetkazilgan"),
    (5, "Qaytarilgan")
)

class Cart(Code):
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    status = models.IntegerField(choices=CART_STATUS, default=1)
    date = models.DateTimeField(auto_now_add=True)


    @property
    def cart_total_price(self):
        n = 0
        for i in CartProduct.objects.filter(cart=self):
            if i.product is not None:
                n += i.total_price
        return n


    @property
    def discount_total_price(self):
        n = 0
        for i in CartProduct.objects.filter(cart=self):
            if i.product is not None:
                n += i.discount_price
        return n

    @property
    def count_product(self):
        n = 0
        for i in CartProduct.objects.filter(cart=self):
            if i.product is not None:
                n += 1
        return n

    def __str__(self):
        return f'{self.user} - {self.status}'


class CartProduct(Code):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE)
    count = models.IntegerField()

    @property
    def total_price(self):
        if not self.product:
            return 0
        if self.product.discount_price:
            return self.product.discount_price * self.count
        return self.product.price * self.count

    @property
    def discount_price(self):
        if not self.product or not self.product.discount_price:
            return 0
        return (self.product.price - self.product.discount_price) * self.count

class WishList(models.Model):
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True)
    date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user} - {self.product}'




class EnterProduct(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    count = models.IntegerField()
    date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.product} - {self.count}'

    def save(self, *args, **kwargs):
        """Kirim qo'shilganda/tahrirlanganda mahsulot qoldig'ini to'g'ri yangilaydi."""
        with transaction.atomic():
            old = None
            if self.pk:
                old = (
                    EnterProduct.objects.filter(pk=self.pk)
                    .values('product_id', 'count')
                    .first()
                )

            if old is None:
                # Yangi kirim.
                product = Product.objects.get(pk=self.product_id)
                product.count += self.count
                product.save(update_fields=['count'])
            elif old['product_id'] == self.product_id:
                # Xuddi shu mahsulot: eski kirimni olib tashlab, yangisini qo'shamiz.
                product = Product.objects.get(pk=self.product_id)
                product.count = max(0, product.count - old['count'] + self.count)
                product.save(update_fields=['count'])
            else:
                # Mahsulot almashtirilgan: eskisidan qaytarib, yangisiga qo'shamiz.
                old_product = Product.objects.get(pk=old['product_id'])
                old_product.count = max(0, old_product.count - old['count'])
                old_product.save(update_fields=['count'])

                product = Product.objects.get(pk=self.product_id)
                product.count += self.count
                product.save(update_fields=['count'])

            super().save(*args, **kwargs)


@receiver(post_delete, sender=EnterProduct)
def _restore_stock_after_enter_product_delete(sender, instance, **kwargs):
    """Kirim o'chirilganda uning mahsulot qoldig'ini kamaytiradi."""
    if not instance.product_id:
        return
    product = Product.objects.filter(pk=instance.product_id).first()
    if product is not None:
        product.count = max(0, product.count - instance.count)
        product.save(update_fields=['count'])