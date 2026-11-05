from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('all-products/', views.all_products, name='all_products'),
    path(
        'product-detail/<str:code>/',
        views.product_detail,
        name='product_detail',
    ),
    path(
        'category-filter/<int:category_id>/',
        views.category_filter,
        name='category_filter',
    ),
    path('register/', views.register, name='register'),
    path('login/', views.log_in, name='login'),
    path('logout/', views.log_out, name='logout'),
    path('profile/', views.profile, name='profile'),

    path('wishlist/', views.wishlist, name='wishlist'),
    path(
        'add-wishlist/<str:product_code>/',
        views.add_wishlist,
        name='add_wishlist',
    ),
    path(
        'delete-wishlist/<str:product_code>/',
        views.delete_wishlist,
        name='delete_wishlist',
    ),
    path('cart/', views.cart, name='cart'),
    path(
        'add-to-cart/<str:product_code>/',
        views.add_to_cart,
        name='add_to_cart',
    ),
    path(
        'cart-product-count-plus/<str:cartproduct_code>/',
        views.cart_product_count_pilus,
        name='cart_product_count_pilus',
    ),
    path(
        'cart-product-count-minus/<str:cartproduct_code>/',
        views.cart_product_count_minus,
        name='cart_product_count_minus',
    ),
    path('cart-personal/', views.cart_personal, name='cart_personal'),
    path('order/<str:cart_code>/', views.order, name='order'),
    path('thank-you/', views.thank_you, name='thank_you'),
]
