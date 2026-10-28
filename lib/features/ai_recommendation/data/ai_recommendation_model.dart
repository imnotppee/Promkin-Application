class RecommendedMenu {
  final String name;
  final String mealType;
  final double estimatedPrice;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String reason;

  RecommendedMenu({
    required this.name,
    required this.mealType,
    required this.estimatedPrice,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.reason,
  });

  factory RecommendedMenu.fromJson(Map<String, dynamic> json) {
    return RecommendedMenu(
      name: json['name'] ?? '',
      mealType: json['mealType'] ?? 'มื้อกลางวัน',
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 50.0,
      calories: (json['calories'] as num?)?.toInt() ?? 400,
      protein: (json['protein'] as num?)?.toDouble() ?? 20.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 40.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 10.0,
      reason: json['reason'] ?? 'เมนูแนะนำตามงบประมาณและแคลอรี',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mealType': mealType,
      'estimatedPrice': estimatedPrice,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'reason': reason,
    };
  }
}
