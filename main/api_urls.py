from django.urls import path

from . import api_views

urlpatterns = [
    path('', api_views.ApiRootView.as_view(), name='api-root'),

    # Katalog
    path('categories/', api_views.CategoryListView.as_view(), name='api-categories'),
    path(
        'categories/<int:pk>/',
        api_views.CategoryDetailView.as_view(),
        name='api-category-detail',
    ),
    path('products/', api_views.ProductListView.as_view(), name='api-products'),
    path(
        'product-sections/',
        api_views.ProductSectionsView.as_view(),
        name='api-product-sections',
    ),
    path(
        'products/<str:code>/',
        api_views.ProductDetailView.as_view(),
        name='api-product-detail',
    ),
    path('banners/', api_views.BannerListView.as_view(), name='api-banners'),

    # Autentifikatsiya va profil
    path('auth/register/', api_views.RegisterView.as_view(), name='api-register'),
    path('auth/login/', api_views.LoginView.as_view(), name='api-login'),
    path('auth/logout/', api_views.LogoutView.as_view(), name='api-logout'),
    path('auth/me/', api_views.MeView.as_view(), name='api-me'),

    # Saqlanganlar
    path('wishlist/', api_views.WishlistListView.as_view(), name='api-wishlist'),
    path(
        'wishlist/<str:product_code>/',
        api_views.WishlistItemView.as_view(),
        name='api-wishlist-item',
    ),

    # Savat
    path('cart/', api_views.CartView.as_view(), name='api-cart'),
    path('cart/items/', api_views.CartItemView.as_view(), name='api-cart-items'),
    path(
        'cart/items/<str:cartproduct_code>/',
        api_views.CartItemDetailView.as_view(),
        name='api-cart-item-detail',
    ),

    # Buyurtmalar
    path('orders/', api_views.OrderListView.as_view(), name='api-orders'),
    path(
        'orders/checkout/',
        api_views.CheckoutView.as_view(),
        name='api-checkout',
    ),
    path(
        'orders/<str:code>/',
        api_views.OrderDetailView.as_view(),
        name='api-order-detail',
    ),
]
