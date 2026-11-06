import 'package:flutter_test/flutter_test.dart';
import 'package:quvvat/models/paginated.dart';
import 'package:quvvat/models/product.dart';
import 'package:quvvat/models/product_section.dart';
import 'package:quvvat/utils/formatters.dart';

void main() {
  group('formatPrice', () {
    test('mingliklarni bo\'sh joy bilan ajratadi', () {
      expect(formatPrice(1234567, "so'm"), "1 234 567 so'm");
    });

    test('kasr qismini yaxlitlaydi', () {
      expect(formatPrice(999.6, 'UZS'), '1 000 UZS');
    });
  });

  group('shortCode', () {
    test('kodni 8 belgiga qisqartiradi', () {
      expect(shortCode('abcdefghijkl'), 'abcdefgh');
    });

    test('null uchun bo\'sh satr qaytaradi', () {
      expect(shortCode(null), '');
    });
  });

  group('Product', () {
    test('API javobini to\'g\'ri o\'qiydi', () {
      final product = Product.fromJson({
        'id': 1,
        'code': 'abc',
        'category': {
          'id': 2,
          'name': 'Smesitellar',
          'name_ru': 'Смесители',
          'name_en': 'Mixers',
          'display_name': 'Смесители',
          'logo': '/media/categories/smesitellar.jpg',
          'is_active': true,
        },
        'image': '/media/products/epa_smesitel.jpg',
        'name': 'EPA smesitel',
        'name_ru': 'Смеситель EPA',
        'name_en': 'EPA mixer',
        'display_name': 'Смеситель EPA',
        'description': 'Tavsif',
        'description_ru': 'Описание',
        'description_en': 'Description',
        'display_description': 'Описание',
        'price': 250000,
        'discount_price': 200000,
        'discount_status': true,
        'count': 5,
        'final_price': 200000,
        'discount_percent': 20,
        'created_at': '2026-01-01T10:00:00Z',
        'updated_at': '2026-01-01T10:00:00Z',
      });

      expect(product.displayName, 'Смеситель EPA');
      expect(product.category?.displayName, 'Смесители');
      expect(product.finalPrice, 200000);
      expect(product.discountPercent, 20);
      expect(product.hasDiscount, isTrue);
      expect(product.inStock, isTrue);
    });
  });

  group('ProductSection', () {
    test('bo\'lim va mahsulotlarini o\'qiydi', () {
      final sections = ProductSection.listFrom([
        {
          'category': {
            'id': 2,
            'name': 'Smesitellar',
            'display_name': 'Смесители',
            'logo': null,
            'is_active': true,
          },
          'products': [
            {
              'id': 1,
              'code': 'abc',
              'category': {
                'id': 2,
                'name': 'Smesitellar',
                'display_name': 'Смесители',
                'logo': null,
                'is_active': true,
              },
              'name': 'EPA smesitel',
              'display_name': 'Смеситель EPA',
              'price': 250000,
              'count': 5,
              'final_price': 250000,
              'discount_percent': 0,
            },
          ],
        },
        {
          'category': {'id': 3, 'name': "Bo'sh", 'display_name': "Bo'sh"},
          'products': [],
        },
      ]);

      expect(sections.length, 1);
      expect(sections.first.category.displayName, 'Смесители');
      expect(sections.first.products.single.displayName, 'Смеситель EPA');
    });
  });

  group('Paginated', () {
    test('results va next ni o\'qiydi', () {
      final parsed = Paginated<int>.fromJson(
        {
          'count': 2,
          'next': 'http://localhost/api/products/?page=2',
          'previous': null,
          'results': [1, 2],
        },
        (json) => 0,
      );
      expect(parsed.count, 2);
      expect(parsed.hasMore, isTrue);
    });

    test('oddiy ro\'yxatni ham qabul qiladi', () {
      final parsed = Paginated<int>.fromJson([1, 2, 3], (json) => 0);
      expect(parsed.results.length, 3);
      expect(parsed.hasMore, isFalse);
    });
  });
}
