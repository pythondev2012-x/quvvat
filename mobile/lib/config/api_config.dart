/// API manzili bilan ishlash.
///
/// Standart manzil Android emulyator uchun `10.0.2.2` (kompyuterning
/// localhost'i). Haqiqiy telefonda ilova sozlamalarida kompyuterning
/// lokal IP manzilini kiritish kerak, masalan:
/// `http://192.168.1.10:8000/api`.
class ApiConfig {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static String baseUrl = defaultBaseUrl;

  /// `http://host:port` ko'rinishidagi manba (rasm URL'lari uchun).
  static String get origin {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      return '';
    }
    final buffer = StringBuffer('${uri.scheme}://${uri.host}');
    if (uri.hasPort) {
      buffer.write(':${uri.port}');
    }
    return buffer.toString();
  }

  /// Backend qaytargan nisbiy rasm yo'lini to'liq URL'ga aylantiradi.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final clean = path.startsWith('/') ? path : '/$path';
    return '$origin$clean';
  }
}
