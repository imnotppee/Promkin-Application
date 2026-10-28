
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase Service for Promkin.
/// Handles Firebase initialization and Cloud Firestore operations.
class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();

  FirebaseService._init();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Initialize Firebase.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _isInitialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase initialization failed: $e');
    }
  }

  /// Ensure Firebase is initialized before accessing Cloud Firestore.
  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'Firebase is not initialized. Check Firebase configuration.',
      );
    }
  }

  // ------------------------------------------------------------
  // Legacy meals collection
  // Kept temporarily for compatibility with existing code.
  // ------------------------------------------------------------

  /// Save or update a meal in the legacy "meals" collection.
  Future<bool> syncMealToCloud(
    Map<String, dynamic> mealData,
  ) async {
    _checkInitialized();

    final id = mealData['id'];

    if (id == null || id.toString().isEmpty) {
      throw ArgumentError('Meal data must contain a valid id.');
    }

    await _firestore
        .collection('meals')
        .doc(id.toString())
        .set(mealData, SetOptions(merge: true));

    debugPrint('Meal synced to legacy collection: $id');
    return true;
  }

  /// Read a meal from the legacy "meals" collection by document ID.
  Future<Map<String, dynamic>?> getMealFromCloud(String id) async {
    _checkInitialized();

    final snapshot = await _firestore.collection('meals').doc(id).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  /// Read all meals from the legacy "meals" collection.
  Future<List<Map<String, dynamic>>> getMealsFromCloud() async {
    _checkInitialized();

    final snapshot = await _firestore.collection('meals').get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // ------------------------------------------------------------
  // Meal plans collection
  // ------------------------------------------------------------

  /// Create or get a meal plan for a user on a specific date.
  Future<String> getOrCreateMealPlan({
    required String userId,
    required DateTime planDate,
  }) async {
    _checkInitialized();

    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID must not be empty.');
    }

    final dateOnly = DateTime(
      planDate.year,
      planDate.month,
      planDate.day,
    );

    final existing = await _firestore
        .collection('meal_plans')
        .where('user_id', isEqualTo: userId)
        .where('plan_date', isEqualTo: Timestamp.fromDate(dateOnly))
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final doc = await _firestore.collection('meal_plans').add({
      'user_id': userId,
      'plan_date': Timestamp.fromDate(dateOnly),
    });

    debugPrint('Meal plan created: ${doc.id}');
    return doc.id;
  }

  // ------------------------------------------------------------
  // Planned meals collection
  // ------------------------------------------------------------

  /// Save or update a planned meal in "planned_meals".
  Future<bool> savePlannedMealToCloud({
    required String mealId,
    required Map<String, dynamic> mealData,
  }) async {
    _checkInitialized();

    if (mealId.trim().isEmpty) {
      throw ArgumentError('Meal ID must not be empty.');
    }

    final mealPlanId = mealData['meal_plan_id'];

    if (mealPlanId == null || mealPlanId.toString().trim().isEmpty) {
      throw ArgumentError('A valid meal_plan_id is required.');
    }

    await _firestore
        .collection('planned_meals')
        .doc(mealId)
        .set(mealData, SetOptions(merge: true));

    debugPrint('Planned meal synced to Cloud Firestore: $mealId');
    return true;
  }

  /// Read a planned meal by document ID.
  Future<Map<String, dynamic>?> getPlannedMealFromCloud(
    String mealId,
  ) async {
    _checkInitialized();

    final snapshot =
        await _firestore.collection('planned_meals').doc(mealId).get();

    if (!snapshot.exists) {
      return null;
    }

    return {
      'id': snapshot.id,
      ...snapshot.data()!,
    };
  }

  /// Read all planned meals.
  Future<List<Map<String, dynamic>>> getPlannedMealsFromCloud() async {
    _checkInitialized();

    final snapshot = await _firestore.collection('planned_meals').get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  // ------------------------------------------------------------
  // User profile
  // ------------------------------------------------------------

  /// Save or update a user profile in "users".
  Future<Map<String, dynamic>?> syncUserProfile(
    String userId,
    Map<String, dynamic> profile,
  ) async {
    _checkInitialized();

    await _firestore
        .collection('users')
        .doc(userId)
        .set(profile, SetOptions(merge: true));

    debugPrint('User profile synced to Cloud Firestore: $userId');

    return profile;
  }
}
