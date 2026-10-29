import 'dart:math';

import 'package:flutter/material.dart';
import '../data/ai_recommendation_model.dart';
import '../../../../core/services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _aiService;
  List<RecommendedMenu> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;
  RecommendedMenu? _dashboardPick;
  bool _isDashboardPickLoading = false;
  String? _dashboardPickError;

  List<RecommendedMenu> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendedMenu? get dashboardPick => _dashboardPick;
  bool get isDashboardPickLoading => _isDashboardPickLoading;
  String? get dashboardPickError => _dashboardPickError;
  String get recommendationSource => _aiService.lastSource;

  AiProvider({AiService? aiService}) : _aiService = aiService ?? AiService();

  Future<void> fetchDashboardPick({
    required double budget,
    required int targetCalories,
    required int mealCount,
    List<String> dislikedIngredients = const [],
    List<String> cuisines = const [],
  }) async {
    _isDashboardPickLoading = true;
    _dashboardPickError = null;
    notifyListeners();

    try {
      final menus = await _aiService.getRecommendations(
        budget: budget,
        targetCalories: targetCalories,
        mealCount: mealCount,
        dislikedIngredients: dislikedIngredients,
        goal: 'สมดุล',
        cuisines: cuisines,
      );
      if (menus.isEmpty) {
        _dashboardPick = null;
        _dashboardPickError = 'ยังไม่มีเมนูที่ตรงกับงบประมาณนี้';
      } else {
        final random = Random(DateTime.now().microsecondsSinceEpoch);
        _dashboardPick = menus[random.nextInt(menus.length)];
      }
    } catch (error) {
      _dashboardPick = null;
      _dashboardPickError = 'โหลดเมนูแนะนำไม่สำเร็จ';
      debugPrint('Could not load dashboard AI pick: $error');
    } finally {
      _isDashboardPickLoading = false;
      notifyListeners();
    }
  }

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
