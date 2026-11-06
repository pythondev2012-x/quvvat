import re

from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.utils.translation import gettext as _

from .models import Banner, Product, Category, WishList, Cart, CartProduct, User
from .selectors import grouped_products
from .tasks import queue_order_notification


def _wishlist_ids_for_user(user):
    if not getattr(user, 'is_authenticated', False):
        return []
    return list(WishList.objects.filter(user=user).values_list('product_id', flat=True))


def index(request):
    categories = Category.objects.all()[:10]
    top_categories = Category.objects.filter(is_active=True)[:7]
    latest_products = Product.objects.all().order_by('-created_at')[:2]
    banners = Banner.objects.select_related('product_1').order_by('id')
    return render(request, 'front/index.html', {
        'categories': categories,
        'top_categories': top_categories,
        'product_sections': grouped_products(limit=8),
        'latest_products': latest_products,
        'banners': banners,
        'wishlist_ids': _wishlist_ids_for_user(request.user),
    })


def product_detail(request, code):
    product = get_object_or_404(Product, code=code)
    return render(request, 'front/detail.html', {'product': product, 'wishlist_ids': _wishlist_ids_for_user(request.user)})


def all_products(request):
    q = request.GET.get('q', '').strip()
    category = request.GET.get('category')
    min_price = request.GET.get('min_price')
    max_price = request.GET.get('max_price')
    price_range = request.GET.get('price', '')

    if price_range and not (min_price or max_price):
        found = re.findall(r"\d+(?:\.\d+)?", price_range)
        if len(found) >= 2:
            min_price, max_price = found[0], found[1]
        elif len(found) == 1:
            min_price = found[0]

    products = Product.objects.all().order_by('-created_at')
    if q:
        products = products.filter(
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
    if category:
        products = products.filter(category_id=category)
    if min_price:
        try:
            products = products.filter(price__gte=float(min_price))
        except (ValueError, TypeError):
            pass
    if max_price:
        try:
            products = products.filter(price__lte=float(max_price))
        except (ValueError, TypeError):
            pass

    categories = Category.objects.all()
    return render(request, 'front/all-products.html', {
        'products': products,
        'categories': categories,
        'wishlist_ids': _wishlist_ids_for_user(request.user),
    })


def category_filter(request, category_id):
    products = Product.objects.filter(category_id=category_id).order_by('-created_at')
    return render(request, 'front/category_filter.html', {'products': products, 'wishlist_ids': _wishlist_ids_for_user(request.user)})


def register(request):
    if request.method != 'POST':
        return render(request, 'front/register.html')
    username = request.POST.get('username')
    phone = request.POST.get('phone')
    password = request.POST.get('password')
    confirm = request.POST.get('confirm_password')
    if not username or not password or password != confirm:
        return render(request, 'front/register.html', {'error': _('Ma`lumotlarni to`g`ri to`ldiring')})
    user = User.objects.create_user(username=username, password=password)
    user.phone = phone
    user.save()
    user = authenticate(username=username, password=password)
    if user:
        login(request, user)
    return redirect('index')


def log_in(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(username=username, password=password)
        if user:
            login(request, user)
            return redirect('index')
        return render(request, 'front/login.html', {'error': _('Noto`g`ri login yoki parol')})
    return render(request, 'front/login.html')


def log_out(request):
    logout(request)
    return redirect('index')


@login_required(login_url='login')
def profile(request):
    if request.method == 'POST':
        u = request.user
        new_username = request.POST.get('username', u.username)
        if new_username != u.username:
            if User.objects.filter(username=new_username).exists():
                return render(request, 'front/profile.html', {
                    'orders': Cart.objects.filter(user=request.user).exclude(status=1).order_by('-date'),
                    'error': _('Bu username allaqachon mavjud')
                })
            u.username = new_username
        u.first_name = request.POST.get('first_name', u.first_name)
        u.last_name = request.POST.get('last_name', u.last_name)
        u.phone = request.POST.get('phone', u.phone)
        u.address = request.POST.get('address', u.address)
        if request.FILES.get('photo'):
            u.photo = request.FILES.get('photo')
        u.save()
    # show user's past orders (exclude active cart status=1)
    orders = Cart.objects.filter(user=request.user).exclude(status=1).order_by('-date')
    return render(request, 'front/profile.html', {
        'orders': orders,
    })


@login_required(login_url='login')
def add_wishlist(request, product_code):
    product = get_object_or_404(Product, code=product_code)
    WishList.objects.get_or_create(user=request.user, product=product)
    return redirect(request.META.get('HTTP_REFERER', 'index'))


@login_required(login_url='login')
def delete_wishlist(request, product_code):
    product = get_object_or_404(Product, code=product_code)
    WishList.objects.filter(user=request.user, product=product).delete()
    return redirect(request.META.get('HTTP_REFERER', 'index'))


@login_required(login_url='login')
def wishlist(request):
    items = WishList.objects.filter(user=request.user).select_related('product')
    return render(request, 'front/wishlist.html', {'wishlist_products': items})


def _get_or_create_cart(user):
    cart = Cart.objects.filter(user=user, status=1).first()
    if cart is None:
        cart = Cart.objects.create(user=user, status=1)
    return cart


@login_required(login_url='login')
def cart(request):
    cart = _get_or_create_cart(request.user)
    cart_products = CartProduct.objects.filter(cart=cart).select_related('product')
    return render(request, 'front/cart.html', {
        'cart_products': cart_products,
        'discount_total_price': cart.discount_total_price,
    })


@login_required(login_url='login')
def add_to_cart(request, product_code):
    product = get_object_or_404(Product, code=product_code)
    cart = _get_or_create_cart(request.user)
    CartProduct.objects.create(cart=cart, product=product, count=1)
    return redirect(request.META.get('HTTP_REFERER', 'index'))


@login_required(login_url='login')
def cart_product_count_pilus(request, cartproduct_code):
    cp = get_object_or_404(CartProduct, code=cartproduct_code)
    cp.count += 1
    cp.save()
    return redirect('cart')


@login_required(login_url='login')
def cart_product_count_minus(request, cartproduct_code):
    cp = get_object_or_404(CartProduct, code=cartproduct_code)
    if cp.count > 1:
        cp.count -= 1
        cp.save()
    else:
        cp.delete()
    return redirect('cart')


@login_required(login_url='login')
def cart_personal(request):
    cart = _get_or_create_cart(request.user)
    cart_products = CartProduct.objects.filter(cart=cart).select_related('product')
    if request.method == 'POST':
        u = request.user
        new_username = request.POST.get('username', u.username)
        if new_username != u.username:
            if User.objects.filter(username=new_username).exists():
                return render(request, 'front/cart-personal.html', {
                    'cart': cart,
                    'cart_products': cart_products,
                    'error': _('Bu username allaqachon mavjud')
                })
            u.username = new_username
        u.address = request.POST.get('address', u.address)
        u.phone = request.POST.get('phone', u.phone)
        u.save()
        latitude = request.POST.get('latitude', '').strip()
        longitude = request.POST.get('longitude', '').strip()
        if latitude and longitude:
            try:
                float(latitude)
                float(longitude)
            except (TypeError, ValueError):
                request.session.pop('order_latitude', None)
                request.session.pop('order_longitude', None)
            else:
                request.session['order_latitude'] = latitude
                request.session['order_longitude'] = longitude
        else:
            request.session.pop('order_latitude', None)
            request.session.pop('order_longitude', None)
        return redirect('order', cart_code=cart.code)
    return render(request, 'front/cart-personal.html', {
        'cart': cart,
        'cart_products': cart_products,
    })


@login_required(login_url='login')
def order(request, cart_code):
    cart = get_object_or_404(Cart, code=cart_code, user=request.user, status=1)
    cart_products = CartProduct.objects.filter(cart=cart).select_related('product')
    for item in cart_products:
        if item.product:
            item.product.count = max(0, item.product.count - item.count)
            item.product.save()
    cart.status = 2
    cart.save()
    latitude = request.session.pop('order_latitude', None)
    longitude = request.session.pop('order_longitude', None)
    queue_order_notification(
        cart.pk,
        [item.pk for item in cart_products],
        latitude=latitude,
        longitude=longitude,
    )
    return render(request, 'front/thank-you.html', {
        'cart': cart,
        'cart_products': cart_products,
    })


def thank_you(request):
    return render(request, 'front/thank-you.html')