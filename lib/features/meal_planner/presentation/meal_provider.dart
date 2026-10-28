import 'package:flutter/material.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/core/utils/date_formatter.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _repository;
  DateTime _selectedDate = DateTime.now();
  List<MealModel> _meals = [];
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;

  MealProvider({MealRepository? repository, bool initDemoMeals = true})
    : _repository = repository ?? MealRepository() {
    if (initDemoMeals) {
      _initDefaultMeals();
    }
    loadMealsForDate(_selectedDate);
  }

  void _initDefaultMeals() {
    final today = DateFormatter.toIso(DateTime.now());
    // Pre-seed demo meals for seamless first run
    _repository.saveMeal(
      MealModel(
        id: 'meal_1',
        name: 'ข้าวต้มกุ้ง + ไข่ต้ม',
        mealType: 'มื้อเช้า',
        price: 50.0,
        calories: 320,
        protein: 18.0,
        carbs: 45.0,
        fat: 6.0,
        date: today,
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'meal_2',
        name: 'ข้าวกะเพราไก่สับ',
        mealType: 'มื้อกลางวัน',
        price: 60.0,
        calories: 550,
        protein: 28.0,
        carbs: 65.0,
        fat: 16.0,
        date: today,
      ),
    );
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadMealsForDate(date);
  }

  Future<void> loadMealsForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    final isoDate = DateFormatter.toIso(date);
    _meals = await _repository.getMealsByDate(isoDate);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeal(MealModel meal) async {
    await _repository.saveMeal(meal);
    await loadMealsForDate(_selectedDate);
  }

  Future<void> removeMeal(String id) async {
    await _repository.deleteMeal(id);
    await loadMealsForDate(_selectedDate);
  }

  Future<void> toggleMealCompletion(MealModel meal) async {
    final updated = meal.copyWith(isCompleted: !meal.isCompleted);
    await _repository.saveMeal(updated);
    await loadMealsForDate(_selectedDate);
  }

  // Calculated totals for selected date
  double get totalSpentToday => _meals.fold(0.0, (sum, m) => sum + m.price);
  int get totalCaloriesToday => _meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProteinToday => _meals.fold(0.0, (sum, m) => sum + m.protein);
  double get totalCarbsToday => _meals.fold(0.0, (sum, m) => sum + m.carbs);
  double get totalFatToday => _meals.fold(0.0, (sum, m) => sum + m.fat);
}
