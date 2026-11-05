import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_client.dart';
import '../utils/parsers.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiClient _api;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  String? _token;
  AppUser? _user;

  String? get token => _token;
  AppUser? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        _user = AppUser.fromJson(asMap(jsonDecode(rawUser)));
      } catch (_) {
        _user = null;
      }
    }
    _api.token = _token;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final data = await _api.post(
      '/auth/login/',
      body: {'username': username.trim(), 'password': password},
    );
    await _applySession(asMap(data));
  }

  Future<void> register({
    required String username,
    required String password,
    required String confirmPassword,
    String email = '',
    String phone = '',
    String address = '',
  }) async {
    final data = await _api.post(
      '/auth/register/',
      body: {
        'username': username.trim(),
        'password': password,
        'confirm_password': confirmPassword,
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
      },
    );
    await _applySession(asMap(data));
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username.trim();
    if (email != null) body['email'] = email.trim();
    if (firstName != null) body['first_name'] = firstName.trim();
    if (lastName != null) body['last_name'] = lastName.trim();
    if (phone != null) body['phone'] = phone.trim();
    if (address != null) body['address'] = address.trim();
    if (body.isEmpty) {
      return;
    }
    final data = await _api.patch('/auth/me/', body: body);
    if (data is Map) {
      _user = AppUser.fromJson(asMap(data));
      await _persistUser();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (isLoggedIn) {
      try {
        await _api.post('/auth/logout/');
      } catch (_) {
        // Serverga ulanish imkoni bo'lmasa ham lokal sessiyani tozalaymiz.
      }
    }
    await _clear();
  }

  Future<void> _applySession(Map<String, dynamic> data) async {
    final newToken = asString(data['token']);
    if (newToken.isEmpty) {
      throw ApiException("Server token qaytarmadi.");
    }
    _token = newToken;
    _user = data['user'] is Map ? AppUser.fromJson(asMap(data['user'])) : null;
    _api.token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    await _persistUser();
    notifyListeners();
  }

  Future<void> _persistUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null) {
      await prefs.remove(_userKey);
    } else {
      await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    }
  }

  Future<void> _clear() async {
    _token = null;
    _user = null;
    _api.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
