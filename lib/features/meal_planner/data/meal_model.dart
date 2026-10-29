import 'package:cloud_firestore/cloud_firestore.dart';

class MealModel {
  final String id;
  final String name;
  final String mealType; // 'มื้อเช้า', 'มื้อกลางวัน', 'มื้อเย็น', 'ของว่าง'
  final double price;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String date; // 'YYYY-MM-DD'
  final bool isCompleted;
  final String? notes;
  final String emoji;
  final String time;
  final List<String> tags;
  final String imageUrl;
  final String source;
  final String? sourceId;
  final String? userId;

  MealModel({
    required this.id,
    required this.name,
    required this.mealType,
    required this.price,
    required this.calories,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    required this.date,
    this.isCompleted = false,
    this.notes,
    this.emoji = '🍛',
    this.time = '12:00',
    this.tags = const [],
    this.imageUrl = '',
    this.source = 'ai',
    this.sourceId,
    this.userId,
  });

  MealModel copyWith({
    String? id,
    String? name,
    String? mealType,
    double? price,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? date,
    bool? isCompleted,
    String? notes,
    String? emoji,
    String? time,
    List<String>? tags,
    String? imageUrl,
    String? source,
    String? sourceId,
    String? userId,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      emoji: emoji ?? this.emoji,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      userId: userId ?? this.userId,
    );
  }

  /// Convert to SQLite map.
  /// Keep the existing field names for compatibility with DatabaseHelper.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType,
      'price': price,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date,
      'isCompleted': isCompleted ? 1 : 0,
      'notes': notes,
      'emoji': emoji,
      'time': time,
      'tags': tags.join(','),
      'imageUrl': imageUrl,
      'source': source,
      'sourceId': sourceId,
      'userId': userId,
    };
  }

  /// Convert to Cloud Firestore format.
  Map<String, dynamic> toFirestoreMap({
    required String mealPlanId,
    String? userId,
    required String source,
    String? sourceId,
  }) {
    final dateTime = DateTime.parse('${date}T$time:00');

    return {
      'meal_plan_id': mealPlanId,
      'user_id': ?userId,
      'source': source,
      'source_id': sourceId ?? this.sourceId,
      'recipe_name': name,
      'meal_type': _toFirestoreMealType(mealType),
      'scheduled_at': Timestamp.fromDate(dateTime),
      'servings': 1,
      'estimated_cost': price,
      'calories': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
    };
  }

  /// Convert meal type to the values defined in the ERD.
  String _toFirestoreMealType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'มื้อเช้า':
      case 'อาหารเช้า':
      case 'breakfast':
        return 'breakfast';

      case 'มื้อกลางวัน':
      case 'อาหารกลางวัน':
      case 'lunch':
        return 'lunch';

      case 'มื้อเย็น':
      case 'อาหารเย็น':
      case 'dinner':
        return 'dinner';

      case 'ของว่าง':
      case 'อาหารว่าง':
      case 'snack':
        return 'snack';

      default:
        return value;
    }
  }

  static double _parsePrice(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];

    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      parsedTags = map['tags'].toString().split(',');
    }

    return MealModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      mealType: map['mealType'] ?? 'มื้อกลางวัน',
      price: _parsePrice(map['price']),
      calories: _parseInt(map['calories']),
      protein: _parsePrice(map['protein']),
      carbs: _parsePrice(map['carbs']),
      fat: _parsePrice(map['fat']),
      date: map['date'] ?? '',
      isCompleted: (map['isCompleted'] == 1 || map['isCompleted'] == true),
      notes: map['notes'],
      emoji: map['emoji'] ?? '🍛',
      time: map['time'] ?? '12:00',
      tags: parsedTags,
      imageUrl: map['imageUrl']?.toString() ?? '',
      source: map['source']?.toString() ?? 'ai',
      sourceId: map['sourceId']?.toString(),
      userId: map['userId']?.toString(),
    );
  }
}
