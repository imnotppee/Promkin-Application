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
    );
  }

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
    };
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
    );
  }
}
