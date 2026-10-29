class RecipeModel {
  final String id;
  final String emoji;
  final String name;
  final String category; // 'อาหารไทย', 'มังสวิรัติ', 'โปรตีนสูง', 'คลีน'
  final int cookingMinutes;
  final int calories;
  final double estimatedPrice;
  final String description;
  final String imageUrl;
  final String area;
  final String sourceUrl;
  final List<Map<String, String>> ingredients;
  final String instructions;
  final List<String> tags;
  final double protein;
  final double carbs;
  final double fat;
  final bool nutritionIsEstimated;

  const RecipeModel({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.cookingMinutes,
    required this.calories,
    required this.estimatedPrice,
    required this.description,
    this.imageUrl = '',
    this.area = '',
    this.sourceUrl = '',
    this.ingredients = const [],
    this.instructions = '',
    this.tags = const [],
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.nutritionIsEstimated = false,
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
      'imageUrl': imageUrl,
      'area': area,
      'sourceUrl': sourceUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'tags': tags,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'nutritionIsEstimated': nutritionIsEstimated,
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
      imageUrl: map['imageUrl'] ?? '',
      area: map['area'] ?? '',
      sourceUrl: map['sourceUrl'] ?? '',
      ingredients:
          (map['ingredients'] as List?)
              ?.whereType<Map>()
              .map(
                (item) => item.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              )
              .toList() ??
          [],
      instructions: map['instructions'] ?? map['description'] ?? '',
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      nutritionIsEstimated: map['nutritionIsEstimated'] as bool? ?? false,
    );
  }
}
