import 'package:flutter/foundation.dart';

import '../models/wishlist_item.dart';
import '../services/api_client.dart';
import '../utils/parsers.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider(this._api);

  final ApiClient _api;

  List<WishlistItem> _items = [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<WishlistItem> get items => _items;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  bool contains(String productCode) {
    return _items.any((item) => item.product?.code == productCode);
  }

  void onAuthChanged(bool loggedIn) {
    if (loggedIn) {
      refresh();
    } else {
      _items = [];
      _error = null;
      _loading = false;
      _loaded = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_api.token == null || _api.token!.isEmpty) {
      _items = [];
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.get('/wishlist/');
      final map = asMap(data);
      final raw = map['results'] ?? data;
      _items = WishlistItem.listFrom(raw);
    } on ApiException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<bool> toggle(String productCode) async {
    if (contains(productCode)) {
      await remove(productCode);
      return false;
    }
    await add(productCode);
    return true;
  }

  Future<void> add(String productCode) async {
    final data = await _api.post('/wishlist/$productCode/');
    final item = WishlistItem.fromJson(asMap(data));
    if (item.id != 0 && !_items.any((existing) => existing.id == item.id)) {
      _items = [item, ..._items];
      notifyListeners();
    }
  }

  Future<void> remove(String productCode) async {
    await _api.delete('/wishlist/$productCode/');
    _items = _items
        .where((item) => item.product?.code != productCode)
        .toList();
    notifyListeners();
  }
}
