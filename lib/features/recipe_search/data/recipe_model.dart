class RecipeModel {
  final String id;
  final String emoji;
  final String name;
  final String category; // 'อาหารไทย', 'มังสวิรัติ', 'โปรตีนสูง', 'คลีน'
  final int cookingMinutes;
  final int calories;
  final double estimatedPrice;
  final String description;
  final List<String> tags;
  final double protein;
  final double carbs;
  final double fat;

  const RecipeModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.cookingMinutes,
    required this.calories,
    required this.estimatedPrice,
    required this.description,
    this.tags = const [],
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'name': name,
      'category': category,
      'cookingMinutes': cookingMinutes,
      'calories': calories,
      'estimatedPrice': estimatedPrice,
      'description': description,
      'tags': tags,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id']?.toString() ?? '',
      emoji: map['emoji'] ?? '🍲',
      name: map['name'] ?? '',
      category: map['category'] ?? 'อาหารไทย',
      cookingMinutes: (map['cookingMinutes'] as num?)?.toInt() ?? 20,
      calories: (map['calories'] as num?)?.toInt() ?? 350,
      estimatedPrice: (map['estimatedPrice'] as num?)?.toDouble() ?? 50.0,
      description: map['description'] ?? '',
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
