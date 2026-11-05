import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class SettingsProvider extends ChangeNotifier {
  static const _languageKey = 'settings_language';
  static const _baseUrlKey = 'settings_base_url';
  static const List<String> supportedLanguages = ['uz', 'ru', 'en'];

  String _language = 'uz';
  String _baseUrl = ApiConfig.defaultBaseUrl;

  String get language => _language;
  String get baseUrl => _baseUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLanguage = prefs.getString(_languageKey);
    if (storedLanguage != null && supportedLanguages.contains(storedLanguage)) {
      _language = storedLanguage;
    }
    final storedUrl = prefs.getString(_baseUrlKey);
    if (storedUrl != null && storedUrl.trim().isNotEmpty) {
      _baseUrl = storedUrl.trim();
    }
    ApiConfig.baseUrl = _baseUrl;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (!supportedLanguages.contains(code) || code == _language) {
      return;
    }
    _language = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  Future<bool> setBaseUrl(String value) async {
    final normalized = normalizeBaseUrl(value);
    if (normalized == null) {
      return false;
    }
    _baseUrl = normalized;
    ApiConfig.baseUrl = normalized;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, normalized);
    return true;
  }

  Future<void> resetBaseUrl() async {
    _baseUrl = ApiConfig.defaultBaseUrl;
    ApiConfig.baseUrl = _baseUrl;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
  }

  /// Foydalanuvchi kiritgan manzilni `http://host:port/api` ko'rinishiga keltiradi.
  static String? normalizeBaseUrl(String value) {
    var text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      text = 'http://$text';
    }
    while (text.endsWith('/')) {
      text = text.substring(0, text.length - 1);
    }
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }
    if (uri.path.isEmpty || uri.path == '/') {
      text = '$text/api';
    }
    return text;
  }

  String languageLabel(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return "O'zbekcha";
    }
  }
}
