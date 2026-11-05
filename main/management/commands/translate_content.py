"""Mavjud mahsulot va kategoriyalar tarjimasini to'ldirish.

Yangi yozuvlar saqlanganda avtomatik tarjima qilinadi. Bu buyruq faqat
eski (tarjimasi bo'sh) yozuvlarni bir marta to'ldirish uchun kerak:

    python manage.py translate_content

Barcha tarjimalarni majburan yangilash:

    python manage.py translate_content --force
"""

from django.core.management.base import BaseCommand

from main.models import Category, Product
from main.translation import translate_category, translate_product


class Command(BaseCommand):
    help = "Mahsulot va kategoriya matnlarini ru/en tillariga tarjima qiladi."

    def add_arguments(self, parser):
        parser.add_argument(
            '--force',
            action='store_true',
            help="Mavjud tarjimalarni ham qayta yozish.",
        )
        parser.add_argument(
            '--only',
            choices=['products', 'categories'],
            help="Faqat mahsulotlar yoki faqat kategoriyalarni tarjima qilish.",
        )

    def handle(self, *args, **options):
        force = options['force']
        only = options['only']

        if only != 'categories':
            products = Product.objects.all()
            product_count = 0
            for product in products.iterator():
                if translate_product(product, force=force):
                    product_count += 1
            self.stdout.write(
                self.style.SUCCESS(f"{product_count} ta mahsulot tarjimasi yangilandi.")
            )

        if only != 'products':
            categories = Category.objects.all()
            category_count = 0
            for category in categories.iterator():
                if translate_category(category, force=force):
                    category_count += 1
            self.stdout.write(
                self.style.SUCCESS(
                    f"{category_count} ta kategoriya tarjimasi yangilandi."
                )
            )
