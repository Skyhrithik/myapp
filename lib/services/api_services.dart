// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 20);

  static Uri _u(String path, [Map<String, dynamic>? q]) => Uri.parse(
    '${AppConfig.baseUrl}$path',
  ).replace(queryParameters: q?.map((k, v) => MapEntry(k, v?.toString())));

  static Map<String, String> get _jsonHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  // ---- Generic response handler ----
  static T _decodeJson<T>(String body) {
    final data = jsonDecode(body);
    return data as T;
  }

  static Never _throwForNon200(http.Response res) {
    String message = 'Request failed (${res.statusCode})';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] != null) {
          message = decoded['detail'].toString();
        } else {
          // Collect DRF field errors if present
          final buf = StringBuffer();
          decoded.forEach((k, v) {
            if (v is List) {
              buf.writeln('$k: ${v.join(', ')}');
            } else {
              buf.writeln('$k: $v');
            }
          });
          final s = buf.toString().trim();
          if (s.isNotEmpty) message = s;
        }
      } else if (decoded is List) {
        message = decoded.join('\n');
      }
    } catch (_) {
      if (res.body.isNotEmpty) message = res.body;
    }
    throw ApiException(message, statusCode: res.statusCode);
  }

  // ===================== AUTH =====================

  /// POST /users/login/
  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    final res = await _client
        .post(
          _u('/users/login/'),
          headers: _jsonHeaders,
          body: jsonEncode({'phone': phone, 'password': password}),
        )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      return _decodeJson<Map<String, dynamic>>(res.body);
    }
    _throwForNon200(res);
  }

  /// POST /users/registration/
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String address,
    required String gender,
    String? confirmPhone, // if backend expects confirm fields, add here
    String? confirmPassword,
  }) async {
    final payload = {
      'name': name,
      'phone': phone,
      'password': password,
      'address': address,
      'gender': gender,
      if (confirmPhone != null) 'confirm_phone': confirmPhone,
      if (confirmPassword != null) 'confirm_password': confirmPassword,
    };

    final res = await _client
        .post(
          _u('/users/registration/'),
          headers: _jsonHeaders,
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    if (res.statusCode == 201 || res.statusCode == 200) {
      return _decodeJson<Map<String, dynamic>>(res.body);
    }
    _throwForNon200(res);
  }

  // ===================== PRODUCTS =====================

  /// GET /products/  (supports optional pagination & search if your API does)
  static Future<List<Product>> getProducts({int? page, String? search}) async {
    final q = <String, dynamic>{};
    if (page != null) q['page'] = page;
    if (search != null && search.trim().isNotEmpty) q['search'] = search.trim();

    final res = await _client.get(_u('/products/', q)).timeout(_timeout);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final list = (decoded is Map && decoded['results'] is List)
          ? decoded['results'] as List
          : (decoded is List ? decoded : <dynamic>[]);

      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _throwForNon200(res);
  }

  /// If you add more endpoints later, keep adding here…
}
