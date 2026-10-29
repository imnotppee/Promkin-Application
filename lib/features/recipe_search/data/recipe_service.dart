import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:promkin_app/core/network/api_endpoints.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_model.dart';

class RecipeService {
  final http.Client _client;

  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<String>> getCategories() async {
    final response = await _client
        .get(Uri.parse('${ApiEndpoints.recipes}/categories'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not load recipe categories');
    }
    final result = jsonDecode(utf8.decode(response.bodyBytes));
    return (result['data'] as List? ?? [])
        .map((item) => item.toString())
        .toList();
  }

  Future<List<RecipeModel>> search({String? query, String? category}) async {
    final uri = Uri.parse(ApiEndpoints.recipes).replace(
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if ((query == null || query.trim().isEmpty) && category != null)
          'category': category,
      },
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Could not load recipes from TheMealDB');
    }
    final result = jsonDecode(utf8.decode(response.bodyBytes));
    return (result['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RecipeModel.fromMap)
        .toList();
  }

  Future<RecipeModel> getDetails(String id) async {
    final response = await _client
        .get(Uri.parse('${ApiEndpoints.recipes}/$id'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Could not load recipe details');
    }
    final result = jsonDecode(utf8.decode(response.bodyBytes));
    return RecipeModel.fromMap(result['data'] as Map<String, dynamic>);
  }
}
