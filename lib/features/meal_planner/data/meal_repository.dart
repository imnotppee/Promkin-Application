import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/core/database/database_helper.dart';
import 'package:promkin_app/core/services/firebase_service.dart';

class MealRepository {
  final DatabaseHelper _dbHelper;
  final FirebaseService _firebaseService;

  // In-memory cache for fast UI updates & test compatibility
  final List<MealModel> _memoryStore = [];

  MealRepository({DatabaseHelper? dbHelper, FirebaseService? firebaseService})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance,
      _firebaseService = firebaseService ?? FirebaseService.instance;

  Future<List<MealModel>> getMealsByDate(String date) async {
    try {
      final dbData = await _dbHelper.getMealsByDate(date);

      if (dbData.isNotEmpty) {
        return dbData.map((e) => MealModel.fromMap(e)).toList();
      }
    } catch (_) {
      // Fallback to memory store in unit tests or environments
      // without a SQLite driver.
    }

    return _memoryStore.where((m) => m.date == date).toList();
  }

  Future<List<MealModel>> getAllMeals() async {
    final byId = {for (final meal in _memoryStore) meal.id: meal};
    try {
      final dbData = await _dbHelper.getAllMeals();
      for (final row in dbData) {
        final meal = MealModel.fromMap(row);
        byId[meal.id] = meal;
      }
    } catch (_) {
      // Keep the in-memory list available when the platform has no SQLite.
    }
    return List<MealModel>.unmodifiable(byId.values);
  }

  Future<void> saveMeal(MealModel meal) async {
    // 1. Save to memory cache.
    _memoryStore.removeWhere((m) => m.id == meal.id);
    _memoryStore.add(meal);

    // 2. Save to local SQLite.
    try {
      await _dbHelper.insertMeal(meal.toMap());
    } catch (_) {
      // Preserve existing fallback behavior.
    }

    // 3. Sync to Firestore.
    // Cloud failures must not prevent local meal planning.
    try {
      if (!_firebaseService.isInitialized) {
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final mealDate = DateTime.parse(meal.date);

      final mealPlanId = await _firebaseService.getOrCreateMealPlan(
        userId: userId,
        planDate: mealDate,
      );

      final firestoreData = meal.toFirestoreMap(
        mealPlanId: mealPlanId,
        source: meal.source,
        sourceId: meal.sourceId,
      );

      await _firebaseService.savePlannedMealToCloud(
        mealId: meal.id,
        mealData: firestoreData,
      );
    } catch (e) {
      // Keep local SQLite and memory data even if Firestore sync fails.
    }
  }

  Future<void> deleteMeal(String id) async {
    // Remove the cloud record as well as local copies for signed-in users.
    try {
      if (_firebaseService.isInitialized &&
          FirebaseAuth.instance.currentUser != null) {
        await _firebaseService.deletePlannedMealFromCloud(id);
      }
    } catch (e) {
      // Keep local planning usable offline; log failed cloud deletes for repair.
      debugPrint('Could not delete planned meal from Firestore: $e');
    }

    _memoryStore.removeWhere((m) => m.id == id);

    try {
      await _dbHelper.deleteMeal(id);
    } catch (_) {
      // Preserve existing fallback behavior.
    }
  }
}
