import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;

  factory ApiException.from(dynamic data, int statusCode) {
    if (data is Map) {
      final map = data.map((key, value) => MapEntry(key.toString(), value));
      if (map['detail'] != null) {
        return ApiException(
          map['detail'].toString(),
          statusCode: statusCode,
          errors: map,
        );
      }
      final messages = <String>[];
      for (final entry in map.entries) {
        final value = entry.value;
        if (value is List) {
          messages.addAll(value.map((item) => item.toString()));
        } else if (value != null) {
          messages.add(value.toString());
        }
      }
      if (messages.isNotEmpty) {
        return ApiException(
          messages.join('\n'),
          statusCode: statusCode,
          errors: map,
        );
      }
    }
    if (statusCode == 401) {
      return ApiException(
        "Avtorizatsiya talab qilinadi. Qaytadan kiring.",
        statusCode: statusCode,
      );
    }
    if (statusCode == 404) {
      return ApiException("Ma'lumot topilmadi.", statusCode: statusCode);
    }
    if (statusCode >= 500) {
      return ApiException(
        "Serverda xatolik yuz berdi. Keyinroq urinib ko'ring.",
        statusCode: statusCode,
      );
    }
    return ApiException("So'rov bajarilmadi ($statusCode).", statusCode: statusCode);
  }
}

class ApiClient {
  ApiClient({required this.languageProvider});

  final String Function() languageProvider;
  String? token;

  static const Duration _timeout = Duration(seconds: 25);

  String get _base {
    var base = ApiConfig.baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base;
  }

  Map<String, String> _headers() {
    return {
      'Accept': 'application/json',
      'Accept-Language': languageProvider(),
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Token $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        params[key] = value.toString();
      }
    });
    return Uri.parse('$_base$normalized').replace(
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final client = http.Client();
    final uri = _uri(path, query);
    final headers = _headers();
    final encoded = body == null ? null : jsonEncode(body);

    try {
      final Future<http.Response> request;
      switch (method) {
        case 'POST':
          request = client.post(uri, headers: headers, body: encoded);
          break;
        case 'PATCH':
          request = client.patch(uri, headers: headers, body: encoded);
          break;
        case 'PUT':
          request = client.put(uri, headers: headers, body: encoded);
          break;
        case 'DELETE':
          request = client.delete(uri, headers: headers);
          break;
        default:
          request = client.get(uri, headers: headers);
      }
      final response = await request.timeout(_timeout);

      if (response.statusCode == 204 || response.bodyBytes.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return null;
        }
      }

      final text = utf8.decode(response.bodyBytes, allowMalformed: true);
      dynamic data;
      if (text.isNotEmpty) {
        try {
          data = jsonDecode(text);
        } catch (_) {
          data = text;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      throw ApiException.from(data, response.statusCode);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        "Server javob bermadi. Manzilni va internetni tekshiring.",
      );
    } on SocketException {
      throw ApiException(
        "Serverga ulanib bo'lmadi. API manzili to'g'riligini tekshiring.",
      );
    } on http.ClientException {
      throw ApiException(
        "Serverga ulanishda xatolik. API manzilini tekshiring.",
      );
    } finally {
      client.close();
    }
  }
}
