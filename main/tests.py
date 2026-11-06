from unittest.mock import patch

from django.test import TestCase, override_settings
from django.utils.translation import override
from rest_framework.test import APIClient

from .models import Cart, Category, Product
from .translation import translate_product


@override_settings(AUTO_TRANSLATE=False)
class ApiSmokeTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.category = Category.objects.create(name='Test kategoriya', is_active=True)
        self.product = Product.objects.create(
            category=self.category,
            name='Test mahsulot',
            description='API test mahsuloti',
            price='100000.00',
            count=10,
        )

    def test_public_catalog(self):
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)

        response = self.client.get(f'/api/products/{self.product.code}/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['name'], self.product.name)

        response = self.client.get('/api/categories/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)

    def test_product_sections(self):
        Category.objects.create(name="Bo'sh kategoriya", is_active=True)

        response = self.client.get('/api/product-sections/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)

        section = response.data['results'][0]
        self.assertEqual(section['category']['id'], self.category.id)
        self.assertEqual(len(section['products']), 1)
        self.assertEqual(section['products'][0]['code'], str(self.product.code))

    def test_register_cart_and_checkout(self):
        response = self.client.post(
            '/api/auth/register/',
            {
                'username': 'api_test_user',
                'password': 'secret123',
                'confirm_password': 'secret123',
                'phone': '998901112233',
            },
            format='json',
        )
        self.assertEqual(response.status_code, 201)
        self.assertIn('token', response.data)
        token = response.data['token']

        self.client.credentials(HTTP_AUTHORIZATION=f'Token {token}')

        response = self.client.post(
            '/api/cart/items/',
            {'product_code': str(self.product.code), 'count': 2},
            format='json',
        )
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['total_quantity'], 2)

        item_code = response.data['items'][0]['code']
        response = self.client.patch(
            f'/api/cart/items/{item_code}/', {'count': 3}, format='json'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['total_quantity'], 3)

        with patch('main.api_views.queue_order_notification') as send_mock:
            with self.captureOnCommitCallbacks(execute=True):
                response = self.client.post(
                    '/api/orders/checkout/',
                    {
                        'phone': '998901112233',
                        'address': 'Toshkent, test manzil',
                        'latitude': 41.311081,
                        'longitude': 69.240562,
                    },
                    format='json',
                )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['status'], 2)
        send_mock.assert_called_once()

        self.product.refresh_from_db()
        self.assertEqual(self.product.count, 7)
        self.assertEqual(Cart.objects.filter(user__username='api_test_user', status=2).count(), 1)

        response = self.client.get('/api/orders/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['count'], 1)


def fake_translation(text, target_language):
    return f'[{target_language}] {text}'


class AutoTranslationTests(TestCase):
    def test_category_is_translated_on_create(self):
        with patch(
            'main.translation.translate_text', side_effect=fake_translation
        ):
            category = Category.objects.create(name='Unitazlar', is_active=True)

        category.refresh_from_db()
        self.assertEqual(category.name_ru, '[ru] Unitazlar')
        self.assertEqual(category.name_en, '[en] Unitazlar')
        with override('ru'):
            self.assertEqual(category.display_name, '[ru] Unitazlar')
        with override('en'):
            self.assertEqual(category.display_name, '[en] Unitazlar')
        with override('uz'):
            self.assertEqual(category.display_name, 'Unitazlar')

    def test_product_is_translated_on_create(self):
        with patch(
            'main.translation.translate_text', side_effect=fake_translation
        ):
            category = Category.objects.create(name='Unitazlar')
            product = Product.objects.create(
                category=category,
                name='Keramik unitaz',
                description='Qulay va gigienik.',
                price='100000.00',
                count=3,
            )

        product.refresh_from_db()
        self.assertEqual(product.name_ru, '[ru] Keramik unitaz')
        self.assertEqual(product.name_en, '[en] Keramik unitaz')
        self.assertEqual(product.description_ru, '[ru] Qulay va gigienik.')
        self.assertEqual(product.description_en, '[en] Qulay va gigienik.')
        with override('ru'):
            self.assertEqual(product.display_name, '[ru] Keramik unitaz')
            self.assertEqual(
                product.display_description, '[ru] Qulay va gigienik.'
            )

    def test_existing_translation_is_not_overwritten(self):
        with patch(
            'main.translation.translate_text', side_effect=fake_translation
        ):
            category = Category.objects.create(name='Unitazlar')
            product = Product.objects.create(
                category=category,
                name='Keramik unitaz',
                name_ru='Qo‘lda yozilgan',
                description='Qulay va gigienik.',
                price='100000.00',
                count=3,
            )

        product.refresh_from_db()
        self.assertEqual(product.name_ru, 'Qo‘lda yozilgan')
        self.assertEqual(product.name_en, '[en] Keramik unitaz')

        with patch('main.translation.translate_text', return_value='Yangi tarjima'):
            translate_product(product, force=True)

        product.refresh_from_db()
        self.assertEqual(product.name_ru, 'Yangi tarjima')
        self.assertEqual(product.name_en, 'Yangi tarjima')
        self.assertEqual(product.description_ru, 'Yangi tarjima')
        self.assertEqual(product.description_en, 'Yangi tarjima')

    def test_failed_translation_falls_back_to_source(self):
        with patch('main.translation.translate_text', return_value=None):
            category = Category.objects.create(name='Unitazlar')
            product = Product.objects.create(
                category=category,
                name='Keramik unitaz',
                description='Qulay va gigienik.',
                price='100000.00',
                count=3,
            )

        product.refresh_from_db()
        self.assertEqual(product.name_ru, '')
        self.assertEqual(product.name_en, '')
        with override('ru'):
            self.assertEqual(product.display_name, 'Keramik unitaz')
            self.assertEqual(product.display_description, 'Qulay va gigienik.')

    def test_api_exposes_translations(self):
        with patch(
            'main.translation.translate_text', side_effect=fake_translation
        ):
            category = Category.objects.create(name='Unitazlar')
            product = Product.objects.create(
                category=category,
                name='Keramik unitaz',
                description='Qulay va gigienik.',
                price='100000.00',
                count=3,
            )

        client = APIClient()
        response = client.get(
            f'/api/products/{product.code}/', HTTP_ACCEPT_LANGUAGE='ru'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['name_ru'], '[ru] Keramik unitaz')
        self.assertEqual(response.data['display_name'], '[ru] Keramik unitaz')
        self.assertEqual(response.data['category']['name_ru'], '[ru] Unitazlar')
        self.assertEqual(
            response.data['category']['display_name'], '[ru] Unitazlar'
        )
