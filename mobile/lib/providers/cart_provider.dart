import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../services/api_client.dart';
import '../utils/parsers.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._api);

  final ApiClient _api;

  Cart _cart = Cart.empty();
  bool _loading = false;
  String? _error;

  Cart get cart => _cart;
  bool get loading => _loading;
  String? get error => _error;
  int get totalQuantity => _cart.totalQuantity;

  void onAuthChanged(bool loggedIn) {
    if (loggedIn) {
      refresh();
    } else {
      _cart = Cart.empty();
      _error = null;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_api.token == null || _api.token!.isEmpty) {
      _cart = Cart.empty();
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.get('/cart/');
      _cart = Cart.fromJson(asMap(data));
    } on ApiException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(String productCode, {int count = 1}) async {
    final data = await _api.post(
      '/cart/items/',
      body: {'product_code': productCode, 'count': count},
    );
    _cart = Cart.fromJson(asMap(data));
    _error = null;
    notifyListeners();
  }

  Future<void> updateQuantity(String itemCode, int count) async {
    final data = await _api.patch(
      '/cart/items/$itemCode/',
      body: {'count': count},
    );
    _cart = Cart.fromJson(asMap(data));
    notifyListeners();
  }

  Future<void> remove(String itemCode) async {
    final data = await _api.delete('/cart/items/$itemCode/');
    _cart = Cart.fromJson(asMap(data));
    notifyListeners();
  }

  Future<void> clear() async {
    await _api.delete('/cart/');
    _cart = Cart.empty();
    notifyListeners();
  }

  void afterCheckout() {
    _cart = Cart.empty();
    _error = null;
    notifyListeners();
  }

  void reset() {
    _cart = Cart.empty();
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
