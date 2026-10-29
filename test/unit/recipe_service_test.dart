import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_service.dart';

void main() {
  group('RecipeService Unit Tests', () {
    test('getCategories parses category list correctly', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': ['Chicken', 'Beef', 'Vegetarian'],
          }),
          200,
        );
      });

      final service = RecipeService(client: client);
      final categories = await service.getCategories();
      expect(categories, ['Chicken', 'Beef', 'Vegetarian']);
    });

    test('getCategories throws Exception on non-200 response', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = RecipeService(client: client);
      expect(() => service.getCategories(), throwsException);
    });

    test('search returns parsed RecipeModel list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'rec_01',
                'name': 'Chicken Rice',
                'category': 'Chicken',
                'calories': 500,
                'estimatedPrice': 60.0,
              },
            ],
          }),
          200,
        );
      });

      final service = RecipeService(client: client);
      final recipes = await service.search(query: 'chicken');
      expect(recipes.length, 1);
      expect(recipes.first.name, 'Chicken Rice');
    });

    test('getDetails returns parsed RecipeModel', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'rec_01',
              'name': 'Chicken Rice Detail',
              'category': 'Chicken',
              'calories': 520,
              'estimatedPrice': 65.0,
            },
          }),
          200,
        );
      });

      final service = RecipeService(client: client);
      final recipe = await service.getDetails('rec_01');
      expect(recipe.id, 'rec_01');
      expect(recipe.name, 'Chicken Rice Detail');
    });
  });
}
