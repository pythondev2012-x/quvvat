import '../utils/parsers.dart';
import 'product.dart';

class BannerItem {
  const BannerItem({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.product,
  });

  final int id;
  final String title;
  final String? image;
  final String description;
  final Product? product;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: asInt(json['id']),
      title: asString(json['title']),
      image: json['image'] == null ? null : asString(json['image']),
      description: asString(json['description']),
      product: json['product_1'] is Map
          ? Product.fromJson(asMap(json['product_1']))
          : null,
    );
  }

  static List<BannerItem> listFrom(dynamic data) {
    return asList(data)
        .map((item) => BannerItem.fromJson(asMap(item)))
        .where((banner) => banner.id != 0)
        .toList();
  }
}
