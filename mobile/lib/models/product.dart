import '../utils/parsers.dart';
import 'category.dart';

class Product {
  const Product({
    required this.id,
    required this.code,
    required this.category,
    required this.image,
    required this.name,
    required this.displayName,
    required this.description,
    required this.displayDescription,
    required this.price,
    required this.discountPrice,
    required this.discountStatus,
    required this.count,
    required this.finalPrice,
    required this.discountPercent,
    required this.createdAt,
  });

  final int id;
  final String code;
  final Category? category;
  final String? image;
  final String name;
  final String displayName;
  final String description;
  final String displayDescription;
  final double price;
  final double? discountPrice;
  final bool discountStatus;
  final int count;
  final double finalPrice;
  final int discountPercent;
  final String? createdAt;

  bool get inStock => count > 0;
  bool get hasDiscount => discountStatus && discountPrice != null;

  factory Product.fromJson(Map<String, dynamic> json) {
    final name = asString(json['name']);
    final price = asDouble(json['price']);
    final discountRaw = json['discount_price'];
    return Product(
      id: asInt(json['id']),
      code: asString(json['code']),
      category: json['category'] is Map
          ? Category.fromJson(asMap(json['category']))
          : null,
      image: json['image'] == null ? null : asString(json['image']),
      name: name,
      displayName: asString(json['display_name'], name),
      description: asString(json['description']),
      displayDescription: asString(
        json['display_description'],
        asString(json['description']),
      ),
      price: price,
      discountPrice: discountRaw == null ? null : asDouble(discountRaw),
      discountStatus: asBool(json['discount_status']),
      count: asInt(json['count']),
      finalPrice: asDouble(json['final_price'], price),
      discountPercent: asInt(json['discount_percent']),
      createdAt: json['created_at'] == null
          ? null
          : asString(json['created_at']),
    );
  }

  static List<Product> listFrom(dynamic data) {
    return asList(data)
        .map((item) => Product.fromJson(asMap(item)))
        .where((product) => product.id != 0 && product.code.isNotEmpty)
        .toList();
  }
}
