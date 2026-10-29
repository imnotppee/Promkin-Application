import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:promkin_app/core/network/api_client.dart';
import 'package:promkin_app/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints Unit Tests', () {
    test('provides valid API endpoint URLs', () {
      expect(ApiEndpoints.localBackendBase, isNotEmpty);
      expect(ApiEndpoints.meals, contains('/meals'));
      expect(ApiEndpoints.recipes, contains('/recipes'));
      expect(ApiEndpoints.aiRecommend, contains('/ai/recommend'));
      expect(ApiEndpoints.authLogin, contains('/auth/login'));
      expect(ApiEndpoints.authRegister, contains('/auth/register'));
      expect(ApiEndpoints.geminiApiBase, isNotEmpty);
      expect(ApiEndpoints.foodApiBase, isNotEmpty);
      expect(ApiEndpoints.mockApiBase, isNotEmpty);
    });
  });

  group('ApiClient and ApiException Unit Tests', () {
    test('ApiException formats toString correctly', () {
      final ex = ApiException('Server error', 500);
      expect(ex.message, 'Server error');
      expect(ex.statusCode, 500);
      expect(ex.toString(), contains('500'));
    });

    test('ApiClient get returns parsed JSON on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final client = ApiClient(client: mockClient);
      final result = await client.get('http://localhost:5000/api/meals');
      expect(result['status'], 'ok');
    });

    test('ApiClient get handles empty response body on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 204);
      });

      final client = ApiClient(client: mockClient);
      final result = await client.get('http://localhost:5000/api/meals');
      expect(result, isEmpty);
    });

    test('ApiClient get throws ApiException on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final client = ApiClient(client: mockClient);
      expect(
        () => client.get('http://localhost:5000/api/notfound'),
        throwsA(isA<ApiException>()),
      );
    });

    test('ApiClient post sends body and parses response', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['name'], 'ข้าวมันไก่');
        return http.Response(jsonEncode({'success': true}), 201);
      });

      final client = ApiClient(client: mockClient);
      final result = await client.post(
        'http://localhost:5000/api/meals',
        body: {'name': 'ข้าวมันไก่'},
      );
      expect(result['success'], isTrue);
    });

    test('ApiClient wraps network errors into ApiException', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection refused');
      });

      final client = ApiClient(client: mockClient);
      expect(
        () => client.get('http://localhost:5000/api/fail'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
