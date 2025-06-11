import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiService({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('GET isteği başarısız oldu: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('POST isteği başarısız oldu: $e');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('PUT isteği başarısız oldu: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('DELETE isteği başarısız oldu: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('API isteği başarısız oldu: ${response.statusCode} - ${response.body}');
    }
  }
}
