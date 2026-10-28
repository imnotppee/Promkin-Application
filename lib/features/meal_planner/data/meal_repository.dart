
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/core/database/database_helper.dart';
import 'package:promkin_app/core/services/firebase_service.dart';

class MealRepository {
  final DatabaseHelper _dbHelper;
  final FirebaseService _firebaseService;

  // In-memory cache for fast UI updates & test compatibility
  final List<MealModel> _memoryStore = [];

  // Demo user ID used by the current AuthProvider.
  // Replace this with the authenticated user's ID when real Firebase
  // Authentication is implemented.
  static const String _defaultUserId = 'usr_001';

  MealRepository({
    DatabaseHelper? dbHelper,
    FirebaseService? firebaseService,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance,
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

      final mealDate = DateTime.parse(meal.date);

      final mealPlanId = await _firebaseService.getOrCreateMealPlan(
        userId: _defaultUserId,
        planDate: mealDate,
      );

      final firestoreData = meal.toFirestoreMap(
        mealPlanId: mealPlanId,
        source: 'ai',
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
    _memoryStore.removeWhere((m) => m.id == id);

    try {
      await _dbHelper.deleteMeal(id);
    } catch (_) {
      // Preserve existing fallback behavior.
    }
  }
}
