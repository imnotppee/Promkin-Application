import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_model.dart';

void main() {
  group('RecipeModel Unit Tests', () {
    test('should serialize to Map and deserialize from Map correctly', () {
      const recipe = RecipeModel(
        id: 'rec_test',
        emoji: '🍲',
        name: 'ต้มข่าไก่',
        category: 'อาหารไทย',
        cookingMinutes: 25,
        calories: 420,
        estimatedPrice: 65.0,
        description: 'กะทิสด อกไก่ เห็ดฟาง ข่า ตะไคร้',
        tags: ['อาหารไทย', 'ต้ม'],
        protein: 28.0,
        carbs: 12.0,
        fat: 22.0,
      );

      final map = recipe.toMap();
      final fromMap = RecipeModel.fromMap(map);

      expect(fromMap.id, 'rec_test');
      expect(fromMap.emoji, '🍲');
      expect(fromMap.name, 'ต้มข่าไก่');
      expect(fromMap.category, 'อาหารไทย');
      expect(fromMap.cookingMinutes, 25);
      expect(fromMap.calories, 420);
      expect(fromMap.estimatedPrice, 65.0);
      expect(fromMap.protein, 28.0);
      expect(fromMap.carbs, 12.0);
      expect(fromMap.fat, 22.0);
      expect(fromMap.tags, contains('อาหารไทย'));
    });

    test('should fallback to defaults when fromMap receives missing keys', () {
      final fromMap = RecipeModel.fromMap({});
      expect(fromMap.id, isEmpty);
      expect(fromMap.emoji, '🍲');
      expect(fromMap.name, isEmpty);
      expect(fromMap.cookingMinutes, 20);
      expect(fromMap.calories, 350);
      expect(fromMap.estimatedPrice, 50.0);
    });
  });
}

