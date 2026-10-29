import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/core/utils/date_formatter.dart';
import 'package:promkin_app/core/database/preferences_helper.dart';
import 'package:promkin_app/core/services/notification_service.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _repository;
  DateTime _selectedDate = DateTime.now();
  List<MealModel> _meals = [];
  List<MealModel> _allMeals = [];
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;
  String? _loadedUserId;
  int _loadGeneration = 0;

  DateTime get selectedDate => _selectedDate;
  List<MealModel> get meals => _meals;
  List<MealModel> get allMeals => _allMeals;
  bool get isLoading => _isLoading;

  MealProvider({MealRepository? repository, bool initDemoMeals = false})
    : _repository = repository ?? MealRepository() {
    _loadedUserId = _activeUserId;
    if (initDemoMeals) {
      _initDefaultMeals();
    }
    loadAllMeals();
    loadMealsForDate(_selectedDate);
    _listenForAccountChanges();
  }

  Future<void> loadAllMeals() async {
    final userId = _activeUserId;
    final generation = _loadGeneration;
    final meals = await _repository.getAllMeals();
    if (generation != _loadGeneration || userId != _activeUserId) return;
    _allMeals = meals;
    await NotificationService.instance.syncMealReminders(
      meals,
      enabled: PreferencesHelper.isReminderEnabled(),
    );
    notifyListeners();
  }

  String? get _activeUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  void _listenForAccountChanges() {
    try {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
        user,
      ) {
        final nextUserId = user?.uid;
        if (nextUserId == _loadedUserId) return;

        _loadedUserId = nextUserId;
        _loadGeneration++;
        _meals = [];
        _allMeals = [];
        notifyListeners();
        loadAllMeals();
        loadMealsForDate(_selectedDate);
      });
    } catch (_) {
      // Firebase can be unavailable in local-only and widget-test contexts.
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _initDefaultMeals() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    String dateForOffset(int dayOffset) {
      return DateFormatter.toIso(monday.add(Duration(days: dayOffset)));
    }

    // Monday (0)
    _repository.saveMeal(
      MealModel(
        id: 'seed_mon_1',
        name: 'โจ๊กหมูใส่ไข่',
        mealType: 'มื้อเช้า',
        price: 40.0,
        calories: 310,
        protein: 15.0,
        carbs: 45.0,
        fat: 8.0,
        date: dateForOffset(0),
        emoji: '🥣',
        time: '08:00',
        tags: ['อิ่มสบาย', 'มื้อเช้า'],
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'seed_mon_2',
        name: 'ข้าวไก่ย่าง + ส้มตำ',
        mealType: 'มื้อกลางวัน',
        price: 65.0,
        calories: 560,
        protein: 34.0,
        carbs: 65.0,
        fat: 14.0,
        date: dateForOffset(0),
        emoji: '🍗',
        time: '12:30',
        tags: ['โปรตีนสูง', 'อาหารไทย'],
      ),
    );

    // Tuesday (1)
    _repository.saveMeal(
      MealModel(
        id: 'seed_tue_1',
        name: 'ไข่กระทะ + ขนมปังโฮลวีต',
        mealType: 'มื้อเช้า',
        price: 35.0,
        calories: 320,
        protein: 20.0,
        carbs: 30.0,
        fat: 12.0,
        date: dateForOffset(1),
        emoji: '🍳',
        time: '07:30',
        tags: ['โปรตีนสูง', 'ทำง่าย'],
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'seed_tue_2',
        name: 'ก๋วยเตี๋ยวต้มยำหมู',
        mealType: 'มื้อกลางวัน',
        price: 55.0,
        calories: 480,
        protein: 24.0,
        carbs: 62.0,
        fat: 14.0,
        date: dateForOffset(1),
        emoji: '🍜',
        time: '12:00',
        tags: ['อาหารไทย', 'รสแซ่บ'],
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'seed_tue_3',
        name: 'ข้าวกะเพราเต้าหู้ไข่',
        mealType: 'มื้อเย็น',
        price: 45.0,
        calories: 380,
        protein: 18.0,
        carbs: 52.0,
        fat: 10.0,
        date: dateForOffset(1),
        emoji: '🍛',
        time: '18:30',
        tags: ['มังสวิรัติ', 'AI แนะนำ'],
      ),
    );

    // Wednesday (2)
    _repository.saveMeal(
      MealModel(
        id: 'seed_wed_1',
        name: 'แซนด์วิชทูน่า',
        mealType: 'มื้อเช้า',
        price: 42.0,
        calories: 345,
        protein: 22.0,
        carbs: 38.0,
        fat: 11.0,
        date: dateForOffset(2),
        emoji: '🥪',
        time: '07:30',
        tags: ['ทำง่าย', 'มื้อเช้า'],
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'seed_wed_2',
        name: 'ข้าวไข่ข้นกุ้ง',
        mealType: 'มื้อกลางวัน',
        price: 60.0,
        calories: 510,
        protein: 26.0,
        carbs: 60.0,
        fat: 15.0,
        date: dateForOffset(2),
        emoji: '🍲',
        time: '12:00',
        tags: ['อาหารไทย', 'โปรตีนสูง'],
      ),
    );

    // Thursday (3)
    _repository.saveMeal(
      MealModel(
        id: 'seed_thu_1',
        name: 'ข้าวผัดไข่ + ผักรวม',
        mealType: 'มื้อกลางวัน',
        price: 50.0,
        calories: 390,
        protein: 16.0,
        carbs: 55.0,
        fat: 12.0,
        date: dateForOffset(3),
        emoji: '🍚',
        time: '12:00',
        tags: ['ทำง่าย', 'ประหยัด'],
      ),
    );

    // Friday (4)
    _repository.saveMeal(
      MealModel(
        id: 'seed_fri_1',
        name: 'สุกี้น้ำไก่',
        mealType: 'มื้อกลางวัน',
        price: 50.0,
        calories: 360,
        protein: 31.0,
        carbs: 34.0,
        fat: 8.0,
        date: dateForOffset(4),
        emoji: '🍲',
        time: '12:30',
        tags: ['โปรตีนสูง', 'คลีน'],
      ),
    );
    _repository.saveMeal(
      MealModel(
        id: 'seed_fri_2',
        name: 'ยำวุ้นเส้นหมูสับ',
        mealType: 'มื้อเย็น',
        price: 48.0,
        calories: 290,
        protein: 18.0,
        carbs: 36.0,
        fat: 7.0,
        date: dateForOffset(4),
        emoji: '🥗',
        time: '18:30',
        tags: ['คลีน', 'แคลอรีต่ำ'],
      ),
    );

    // Saturday (5)
    _repository.saveMeal(
      MealModel(
        id: 'seed_sat_1',
        name: 'ข้าวเต้าหู้เทอริยากิ',
        mealType: 'มื้อกลางวัน',
        price: 58.0,
        calories: 430,
        protein: 22.0,
        carbs: 58.0,
        fat: 11.0,
        date: dateForOffset(5),
        emoji: '🍱',
        time: '12:00',
        tags: ['ญี่ปุ่น', 'มังสวิรัติ'],
      ),
    );

    // Sunday (6)
    _repository.saveMeal(
      MealModel(
        id: 'seed_sun_1',
        name: 'ก๋วยเตี๋ยวเรือหมู',
        mealType: 'มื้อกลางวัน',
        price: 50.0,
        calories: 410,
        protein: 20.0,
        carbs: 52.0,
        fat: 12.0,
        date: dateForOffset(6),
        emoji: '🍜',
        time: '12:30',
        tags: ['อาหารไทย', 'มื้อกลางวัน'],
      ),
    );
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadMealsForDate(date);
  }

  Future<void> loadMealsForDate(DateTime date) async {
    final userId = _activeUserId;
    final generation = _loadGeneration;
    _isLoading = true;
    notifyListeners();

    final isoDate = DateFormatter.toIso(date);
    final meals = await _repository.getMealsByDate(isoDate);
    if (generation != _loadGeneration || userId != _activeUserId) return;
    _meals = meals;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMeal(MealModel meal) async {
    await _repository.saveMeal(meal);
    await loadAllMeals();
    await loadMealsForDate(_selectedDate);
  }

  Future<void> removeMeal(String id) async {
    await _repository.deleteMeal(id);
    await loadAllMeals();
    await loadMealsForDate(_selectedDate);
  }

  Future<void> toggleMealCompletion(MealModel meal) async {
    final updated = meal.copyWith(isCompleted: !meal.isCompleted);
    await _repository.saveMeal(updated);
    await loadAllMeals();
    await loadMealsForDate(_selectedDate);
  }

  // Calculated totals for selected date
  double get totalSpentToday => _meals.fold(0.0, (sum, m) => sum + m.price);
  int get totalCaloriesToday => _meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProteinToday => _meals.fold(0.0, (sum, m) => sum + m.protein);
  double get totalCarbsToday => _meals.fold(0.0, (sum, m) => sum + m.carbs);
  double get totalFatToday => _meals.fold(0.0, (sum, m) => sum + m.fat);
}
