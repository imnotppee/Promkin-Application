import 'package:flutter/material.dart';
import '../data/ai_recommendation_model.dart';
import '../../../../core/services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _aiService;
  List<RecommendedMenu> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RecommendedMenu> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get recommendationSource => _aiService.lastSource;

  AiProvider({AiService? aiService}) : _aiService = aiService ?? AiService();

  Future<void> fetchRecommendations({
    required double budget,
    required int targetCalories,
    required int mealCount,
    List<String> dislikedIngredients = const [],
    String goal = 'balanced',
    List<String> cuisines = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await _aiService.getRecommendations(
        budget: budget,
        targetCalories: targetCalories,
        mealCount: mealCount,
        dislikedIngredients: dislikedIngredients,
        goal: goal,
        cuisines: cuisines,
      );
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาดในการขอคำแนะนำจาก AI: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
