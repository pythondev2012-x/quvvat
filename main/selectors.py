"""Katalog bo'limlari uchun so'rovlar.

Mahsulotlar sayt va mobil ilovada bir xil tartibda, kategoriya bo'yicha
bo'limlarga guruhlanadi.
"""

from .models import Category, Product


def grouped_products(limit=8):
    """Har bir faol kategoriya va uning oxirgi mahsulotlarini qaytaradi.

    Bo'sh kategoriyalar tashlab yuboriladi. `limit` — bitta bo'limdagi
    ko'rsatiladigan mahsulotlarning maksimal soni.
    """

    sections = []
    categories = Category.objects.filter(is_active=True).order_by('id')
    for category in categories:
        products = list(
            Product.objects.filter(category=category)
            .select_related('category')
            .order_by('-created_at')[:limit]
        )
        if products:
            sections.append({'category': category, 'products': products})
    return sections
