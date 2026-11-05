"""Quvvat admin dashboard uchun kontekst hisoblagichlari."""

from datetime import timedelta

from django.db.models import DecimalField, ExpressionWrapper, F, Sum
from django.db.models.functions import Coalesce, NullIf
from django.urls import reverse
from django.utils import timezone

from .models import CART_STATUS, Cart, CartProduct, Category, Product, User


STATUS_TONES = {
    1: "idle",
    2: "packing",
    3: "shipping",
    4: "done",
    5: "returned",
}


def _number(value):
    try:
        number = int(value or 0)
    except (TypeError, ValueError):
        number = 0
    return f"{number:,}".replace(",", " ")


def low_stock_badge(request):
    count = Product.objects.filter(count__lte=5).count()
    return count or ""


def new_orders_badge(request):
    count = Cart.objects.filter(status=1).count()
    return count or ""


def dashboard_callback(request, context):
    now = timezone.now()
    week_ago = now - timedelta(days=7)
    today = timezone.localdate()

    carts = Cart.objects.select_related("user")
    products = Product.objects.select_related("category")

    orders_count = carts.count()
    week_orders = carts.filter(date__gte=week_ago).count()
    revenue = (
        CartProduct.objects.filter(cart__status__in=[2, 3, 4]).aggregate(
            total=Sum(
                ExpressionWrapper(
                    F("count")
                    * Coalesce(
                        NullIf(F("product__discount_price"), 0),
                        F("product__price"),
                    ),
                    output_field=DecimalField(max_digits=14, decimal_places=2),
                )
            )
        )["total"]
        or 0
    )
    low_stock_count = products.filter(count__lte=5).count()
    new_users = User.objects.filter(date_joined__gte=week_ago).count()

    statuses = []
    for value, label in CART_STATUS:
        count = carts.filter(status=value).count()
        statuses.append(
            {
                "label": label,
                "count": count,
                "percent": round((count / orders_count) * 100) if orders_count else 0,
                "tone": STATUS_TONES.get(value, "idle"),
            }
        )

    recent_orders = list(carts.order_by("-date")[:6])
    for order in recent_orders:
        order.qv_tone = STATUS_TONES.get(order.status, "idle")
        order.qv_total = _number(order.cart_total_price)
        order.qv_items = order.count_product

    context.update(
        {
            "qv_today": today,
            "qv_stats": [
                {
                    "label": "Mahsulotlar",
                    "value": _number(products.count()),
                    "hint": f"{Category.objects.count()} kategoriya · {low_stock_count} ta kam qoldi",
                    "icon": "inventory_2",
                    "url": reverse("admin:main_product_changelist"),
                },
                {
                    "label": "Buyurtmalar",
                    "value": _number(orders_count),
                    "hint": f"{week_orders} ta shu hafta",
                    "icon": "receipt_long",
                    "url": reverse("admin:main_cart_changelist"),
                },
                {
                    "label": "Tushum",
                    "value": _number(revenue),
                    "suffix": "so'm",
                    "hint": "Faol buyurtmalar bo'yicha",
                    "icon": "payments",
                    "url": reverse("admin:main_cart_changelist"),
                },
                {
                    "label": "Mijozlar",
                    "value": _number(User.objects.count()),
                    "hint": f"+{new_users} ta shu hafta",
                    "icon": "group",
                    "url": reverse("admin:main_user_changelist"),
                },
            ],
            "qv_statuses": statuses,
            "qv_recent_orders": recent_orders,
            "qv_low_stock": products.filter(count__lte=5).order_by("count")[:5],
            "qv_top_products": (
                products.annotate(sold=Sum("cartproduct__count"))
                .filter(sold__gt=0)
                .order_by("-sold")[:4]
            ),
            "qv_quick_links": [
                {
                    "label": "Mahsulot qo'shish",
                    "icon": "add_box",
                    "url": reverse("admin:main_product_add"),
                },
                {
                    "label": "Kategoriya qo'shish",
                    "icon": "create_new_folder",
                    "url": reverse("admin:main_category_add"),
                },
                {
                    "label": "Banner qo'shish",
                    "icon": "add_photo_alternate",
                    "url": reverse("admin:main_banner_add"),
                },
                {
                    "label": "Kirim qayd etish",
                    "icon": "add_shopping_cart",
                    "url": reverse("admin:main_enterproduct_add"),
                },
            ],
        }
    )

    return context
