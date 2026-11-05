import '../utils/parsers.dart';
import 'product.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.code,
    required this.product,
    required this.count,
    required this.totalPrice,
    required this.discountPrice,
  });

  final int id;
  final String code;
  final Product? product;
  final int count;
  final double totalPrice;
  final double discountPrice;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: asInt(json['id']),
      code: asString(json['code']),
      product: json['product'] is Map
          ? Product.fromJson(asMap(json['product']))
          : null,
      count: asInt(json['count']),
      totalPrice: asDouble(json['total_price']),
      discountPrice: asDouble(json['discount_price']),
    );
  }
}

class Cart {
  const Cart({
    required this.id,
    required this.code,
    required this.status,
    required this.statusDisplay,
    required this.date,
    required this.items,
    required this.cartTotalPrice,
    required this.discountTotalPrice,
    required this.countProduct,
    required this.totalQuantity,
  });

  final int id;
  final String code;
  final int status;
  final String statusDisplay;
  final String? date;
  final List<CartItem> items;
  final double cartTotalPrice;
  final double discountTotalPrice;
  final int countProduct;
  final int totalQuantity;

  bool get isEmpty => items.isEmpty;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: asInt(json['id']),
      code: asString(json['code']),
      status: asInt(json['status'], 1),
      statusDisplay: asString(json['status_display']),
      date: json['date'] == null ? null : asString(json['date']),
      items: asList(json['items'])
          .map((item) => CartItem.fromJson(asMap(item)))
          .toList(),
      cartTotalPrice: asDouble(json['cart_total_price']),
      discountTotalPrice: asDouble(json['discount_total_price']),
      countProduct: asInt(json['count_product']),
      totalQuantity: asInt(json['total_quantity']),
    );
  }

  static Cart empty() {
    return const Cart(
      id: 0,
      code: '',
      status: 1,
      statusDisplay: '',
      date: null,
      items: [],
      cartTotalPrice: 0,
      discountTotalPrice: 0,
      countProduct: 0,
      totalQuantity: 0,
    );
  }
}
