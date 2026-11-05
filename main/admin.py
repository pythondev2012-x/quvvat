from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.db.models import Count
from django.utils.html import format_html
from unfold.admin import ModelAdmin, TabularInline
from unfold.forms import AdminPasswordChangeForm, UserChangeForm, UserCreationForm

from . import models
from .translation import translate_category, translate_product


STATUS_TONES = {
    1: "idle",
    2: "packing",
    3: "shipping",
    4: "done",
    5: "returned",
}


def _money(value):
    try:
        number = int(value or 0)
    except (TypeError, ValueError):
        number = 0
    return f"{number:,}".replace(",", " ")


@admin.register(models.Category)
class CategoryAdmin(ModelAdmin):
    list_display = ["name", "is_active", "product_count"]
    list_filter = ["is_active"]
    list_editable = ["is_active"]
    search_fields = ["name", "name_ru", "name_en"]
    list_per_page = 30
    actions = ["translate_selected"]

    fieldsets = [
        ("Kategoriya", {"fields": ("logo", "name", "is_active")}),
        (
            "Tarjimalar",
            {
                "fields": (("name_ru", "name_en"),),
                "description": (
                    "Bo'sh maydonlar saqlanganda avtomatik to'ldiriladi. "
                    "Qo'lda tahrirlangan tarjima ustidan yozilmaydi."
                ),
            },
        ),
    ]

    def get_queryset(self, request):
        return super().get_queryset(request).annotate(_product_count=Count("product"))

    @admin.display(description="Mahsulotlar", ordering="_product_count")
    def product_count(self, obj):
        return obj._product_count

    @admin.action(description="Tanlangan kategoriyalarni ru/en ga qayta tarjima qilish")
    def translate_selected(self, request, queryset):
        updated = sum(1 for obj in queryset if translate_category(obj, force=True))
        self.message_user(request, f"{updated} ta kategoriya tarjimasi yangilandi.")


@admin.register(models.Product)
class ProductAdmin(ModelAdmin):
    list_display = [
        "image_tag",
        "name",
        "category",
        "price_display",
        "discount_badge",
        "stock_badge",
        "created_at",
    ]
    list_filter = ["category", "discount_status", ("created_at", admin.DateFieldListFilter)]
    search_fields = [
        "name",
        "name_ru",
        "name_en",
        "description",
        "description_ru",
        "description_en",
        "category__name",
        "category__name_ru",
        "category__name_en",
    ]
    readonly_fields = ["created_at", "updated_at", "image_preview"]
    date_hierarchy = "created_at"
    list_select_related = ["category"]
    list_per_page = 24
    save_on_top = True
    actions = ["translate_selected"]

    fieldsets = [
        (
            "Mahsulot",
            {
                "fields": (
                    ("name", "category"),
                    "description",
                )
            },
        ),
        (
            "Tarjimalar",
            {
                "fields": (
                    ("name_ru", "name_en"),
                    ("description_ru", "description_en"),
                ),
                "description": (
                    "Bo'sh maydonlar saqlanganda avtomatik to'ldiriladi. "
                    "Qo'lda tahrirlangan tarjima ustidan yozilmaydi."
                ),
            },
        ),
        (
            "Narx",
            {
                "fields": (
                    ("price", "discount_price"),
                    "discount_status",
                )
            },
        ),
        ("Ombor", {"fields": ("count",)}),
        ("Rasm", {"fields": ("image", "image_preview")}),
        (
            "Vaqt",
            {
                "fields": (("created_at", "updated_at"),),
                "classes": ("collapse",),
            },
        ),
    ]

    @admin.action(description="Tanlangan mahsulotlarni ru/en ga qayta tarjima qilish")
    def translate_selected(self, request, queryset):
        updated = sum(1 for obj in queryset if translate_product(obj, force=True))
        self.message_user(request, f"{updated} ta mahsulot tarjimasi yangilandi.")

    @admin.display(description="Rasm")
    def image_tag(self, obj):
        if obj and obj.image:
            return format_html(
                '<img src="{}" class="qv-admin-thumb" alt="">', obj.image.url
            )
        return format_html('<span class="qv-admin-thumb--empty">yo‘q</span>')

    @admin.display(description="Ko‘rinish")
    def image_preview(self, obj):
        if obj and obj.image:
            return format_html(
                '<a href="{}" target="_blank" rel="noopener">'
                '<img src="{}" class="qv-admin-thumb" style="width:120px;height:120px" alt=""></a>',
                obj.image.url,
                obj.image.url,
            )
        return "Rasm yuklanmagan."

    @admin.display(description="Narx", ordering="price")
    def price_display(self, obj):
        return format_html("<b>{}</b> <small>so‘m</small>", _money(obj.price))

    @admin.display(description="Chegirma", ordering="discount_status")
    def discount_badge(self, obj):
        if obj.discount_status and obj.discount_price:
            percent = 0
            if obj.price:
                percent = round((obj.price - obj.discount_price) / obj.price * 100)
            return format_html('<span class="qv-discount">−{}%</span>', percent)
        return "—"

    @admin.display(description="Ombor", ordering="count")
    def stock_badge(self, obj):
        if obj.count <= 0:
            tone, label = "out", "Tugagan"
        elif obj.count <= 5:
            tone, label = "low", f"{obj.count} ta"
        else:
            tone, label = "ok", f"{obj.count} ta"
        return format_html(
            '<span class="qv-stock qv-stock--{}">{}</span>', tone, label
        )


class CartProductInline(TabularInline):
    model = models.CartProduct
    extra = 0
    readonly_fields = ["total_price", "discount_price"]
    show_change_link = True
    autocomplete_fields = ["product"]


@admin.register(models.Cart)
class CartAdmin(ModelAdmin):
    list_display = [
        "code_short",
        "user",
        "status_badge",
        "date",
        "items_count",
        "total_display",
    ]
    list_filter = ["status", ("date", admin.DateFieldListFilter)]
    search_fields = ["code", "user__username", "user__phone"]
    readonly_fields = [
        "code",
        "date",
        "cart_total_price",
        "discount_total_price",
        "count_product",
    ]
    date_hierarchy = "date"
    list_select_related = ["user"]
    list_per_page = 30
    inlines = [CartProductInline]
    actions = ["mark_shipping", "mark_delivered"]

    @admin.display(description="Kod", ordering="code")
    def code_short(self, obj):
        return str(obj.code)[:8]

    @admin.display(description="Holat", ordering="status")
    def status_badge(self, obj):
        tone = STATUS_TONES.get(obj.status, "idle")
        return format_html(
            '<span class="qv-badge qv-badge--{}">{}</span>',
            tone,
            obj.get_status_display(),
        )

    @admin.display(description="Mahsulot", ordering="date")
    def items_count(self, obj):
        return f"{obj.count_product} ta"

    @admin.display(description="Summa", ordering="date")
    def total_display(self, obj):
        return format_html("<b>{}</b> <small>so‘m</small>", _money(obj.cart_total_price))

    @admin.action(description="Yo‘lda deb belgilash")
    def mark_shipping(self, request, queryset):
        updated = queryset.update(status=3)
        self.message_user(request, f"{updated} ta buyurtma «Yo‘lda» holatiga o‘tkazildi.")

    @admin.action(description="Yetkazilgan deb belgilash")
    def mark_delivered(self, request, queryset):
        updated = queryset.update(status=4)
        self.message_user(request, f"{updated} ta buyurtma «Yetkazilgan» deb belgilandi.")


@admin.register(models.CartProduct)
class CartProductAdmin(ModelAdmin):
    list_display = [
        "code_short",
        "product",
        "cart",
        "count",
        "total_display",
        "discount_display",
    ]
    list_filter = ["cart__status"]
    search_fields = ["code", "product__name", "cart__code"]
    readonly_fields = ["code", "total_price", "discount_price"]
    list_select_related = ["product", "cart"]
    list_per_page = 40
    autocomplete_fields = ["product", "cart"]

    @admin.display(description="Kod", ordering="code")
    def code_short(self, obj):
        return str(obj.code)[:8]

    @admin.display(description="Summa", ordering="count")
    def total_display(self, obj):
        return format_html("<b>{}</b> <small>so‘m</small>", _money(obj.total_price))

    @admin.display(description="Chegirma")
    def discount_display(self, obj):
        return format_html("<span>{}</span> <small>so‘m</small>", _money(obj.discount_price))


@admin.register(models.Banner)
class BannerAdmin(ModelAdmin):
    list_display = ["image_tag", "title", "product_1"]
    search_fields = ["title", "description"]
    list_select_related = ["product_1"]
    list_per_page = 30

    @admin.display(description="Rasm")
    def image_tag(self, obj):
        if obj and obj.image:
            return format_html(
                '<img src="{}" class="qv-admin-thumb" alt="">', obj.image.url
            )
        return format_html('<span class="qv-admin-thumb--empty">yo‘q</span>')


@admin.register(models.User)
class UserAdmin(BaseUserAdmin, ModelAdmin):
    form = UserChangeForm
    add_form = UserCreationForm
    change_password_form = AdminPasswordChangeForm

    list_display = [
        "username",
        "email",
        "phone",
        "is_staff",
        "is_superuser",
        "is_active",
        "date_joined",
    ]
    list_filter = ["is_staff", "is_superuser", "is_active", ("date_joined", admin.DateFieldListFilter)]
    search_fields = ["username", "email", "phone", "first_name", "last_name"]
    date_hierarchy = "date_joined"
    list_per_page = 30

    fieldsets = BaseUserAdmin.fieldsets + (
        ("Aloqa", {"fields": ("phone", "address", "photo")}),
    )
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ("Aloqa", {"fields": ("phone", "address")}),
    )


@admin.register(models.WishList)
class WishListAdmin(ModelAdmin):
    list_display = ["user", "product", "date"]
    list_filter = [("date", admin.DateFieldListFilter)]
    search_fields = ["user__username", "product__name"]
    list_select_related = ["user", "product"]
    date_hierarchy = "date"
    list_per_page = 40


@admin.register(models.EnterProduct)
class EnterProductAdmin(ModelAdmin):
    list_display = ["product", "count", "date"]
    list_filter = [("date", admin.DateFieldListFilter)]
    search_fields = ["product__name"]
    list_select_related = ["product"]
    autocomplete_fields = ["product"]
    date_hierarchy = "date"
    list_per_page = 40
