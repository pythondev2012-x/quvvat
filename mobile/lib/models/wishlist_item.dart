import '../utils/parsers.dart';
import 'product.dart';

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.product,
    required this.date,
  });

  final int id;
  final Product? product;
  final String? date;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: asInt(json['id']),
      product: json['product'] is Map
          ? Product.fromJson(asMap(json['product']))
          : null,
      date: json['date'] == null ? null : asString(json['date']),
    );
  }

  static List<WishlistItem> listFrom(dynamic data) {
    return asList(data)
        .map((item) => WishlistItem.fromJson(asMap(item)))
        .where((item) => item.id != 0)
        .toList();
  }
}
