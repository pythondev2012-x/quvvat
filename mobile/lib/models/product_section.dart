import '../utils/parsers.dart';
import 'category.dart';
import 'product.dart';

/// Bitta kategoriya va uning mahsulotlari — bosh sahifadagi bo'lim.
class ProductSection {
  const ProductSection({required this.category, required this.products});

  final Category category;
  final List<Product> products;

  factory ProductSection.fromJson(Map<String, dynamic> json) {
    return ProductSection(
      category: Category.fromJson(asMap(json['category'])),
      products: Product.listFrom(json['products']),
    );
  }

  static List<ProductSection> listFrom(dynamic data) {
    return asList(data)
        .map((item) => ProductSection.fromJson(asMap(item)))
        .where((section) => section.category.id != 0 && section.products.isNotEmpty)
        .toList();
  }
}
