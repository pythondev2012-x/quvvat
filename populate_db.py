import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from main.models import Category, Product, Banner, EnterProduct
from django.core.files.base import ContentFile
import requests
from io import BytesIO

def download_image(url, filename):
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return ContentFile(response.content, filename)
    except Exception as e:
        print(f"Error downloading {url}: {e}")
    return None

def populate_data():
    # Create Categories
    categories_data = [
        {'name': 'Smesitellar', 'is_active': True},
        {'name': 'Unitazlar', 'is_active': True},
        {'name': 'Vannalar', 'is_active': True},
        {'name': 'Quvurlar', 'is_active': True},
        {'name': 'Isitish jihozlari', 'is_active': True},
    ]
    
    categories = []
    for cat_data in categories_data:
        cat, created = Category.objects.get_or_create(
            name=cat_data['name'],
            defaults={'is_active': cat_data['is_active']}
        )
        if created:
            # Download category logo
            logo_url = f"https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=200&h=200&fit=crop"
            logo = download_image(logo_url, f"{cat.name.lower()}.jpg")
            if logo:
                cat.logo = logo
                cat.save()
            print(f"Created category: {cat.name}")
        categories.append(cat)
    
    # Create Products
    products_data = [
        {
            'name': 'EPA Smesitel',
            'category': categories[0],
            'description': 'Yuqori sifatli EPA smesitel, zamonaviy dizayn va uzoq muddatli ishlash kafolati.',
            'price': 450000,
            'discount_price': 380000,
            'discount_status': True,
            'count': 15,
            'image_url': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&h=400&fit=crop'
        },
        {
            'name': 'Fermasiniki Smesitel',
            'category': categories[0],
            'description': 'Fermasiniki brendidining eng yaxshi smesiteli, mustahkam va ishonchli.',
            'price': 520000,
            'discount_price': 450000,
            'discount_status': True,
            'count': 20,
            'image_url': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&h=400&fit=crop'
        },
        {
            'name': 'Keramik Unitaz',
            'category': categories[1],
            'description': 'Zamonaviy keramik unitaz, qulay va gigienik.',
            'price': 1200000,
            'discount_price': None,
            'discount_status': False,
            'count': 10,
            'image_url': 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=400&h=400&fit=crop'
        },
        {
            'name': 'Akril Vanna',
            'category': categories[2],
            'description': 'Qulay akril vanna, issiqlikni uzoq saqlaydi.',
            'price': 2500000,
            'discount_price': 2200000,
            'discount_status': True,
            'count': 5,
            'image_url': 'https://images.unsplash.com/photo-1584622050111-993a426fbf0a?w=400&h=400&fit=crop'
        },
        {
            'name': 'Polipropilen Quvur',
            'category': categories[3],
            'description': 'Mustahkam polipropilen quvur, isitish tizimlari uchun.',
            'price': 25000,
            'discount_price': None,
            'discount_status': False,
            'count': 100,
            'image_url': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400&h=400&fit=crop'
        },
    ]
    
    products = []
    for prod_data in products_data:
        image_url = prod_data.pop('image_url')
        category = prod_data.pop('category')
        
        product, created = Product.objects.get_or_create(
            name=prod_data['name'],
            category=category,
            defaults=prod_data
        )
        
        if created:
            image = download_image(image_url, f"{product.name.lower().replace(' ', '_')}.jpg")
            if image:
                product.image = image
                product.save()
            print(f"Created product: {product.name}")
        products.append(product)
    
    # Create Banners
    banners_data = [
        {
            'title': 'Santexnika jihozlari - 20% chegirma',
            'description': 'Barcha smesitellar va unitazlarda katta chegirma!',
            'product_1': products[0],
            'image_url': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=1200&h=400&fit=crop'
        },
        {
            'title': 'Yangi kolleksiya',
            'description': 'Zamonaviy vannalar va isitish jihozlari',
            'product_1': products[3],
            'image_url': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=1200&h=400&fit=crop'
        },
    ]
    
    for banner_data in banners_data:
        image_url = banner_data.pop('image_url')
        product_1 = banner_data.pop('product_1')
        
        banner, created = Banner.objects.get_or_create(
            title=banner_data['title'],
            defaults={**banner_data, 'product_1': product_1}
        )
        
        if created:
            image = download_image(image_url, f"banner_{banner.title.lower().replace(' ', '_')}.jpg")
            if image:
                banner.image = image
                banner.save()
            print(f"Created banner: {banner.title}")
    
    # Create EnterProduct (inventory entries)
    for product in products:
        enter_product, created = EnterProduct.objects.get_or_create(
            product=product,
            defaults={'count': product.count}
        )
        if created:
            print(f"Created inventory entry for: {product.name}")
    
    print("\nDatabase populated successfully!")

if __name__ == '__main__':
    populate_data()
