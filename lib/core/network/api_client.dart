import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
      );

      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );

      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error occurred: $e');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      throw ApiException(
        'HTTP Request failed with status: ${response.statusCode}',
        response.statusCode,
      );
    }
  }
}
