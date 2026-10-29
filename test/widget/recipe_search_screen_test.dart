import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/meal_planner/data/meal_repository.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/recipe_search/presentation/screens/recipe_search_screen.dart';

void main() {
  group('RecipeSearchScreen Widget Tests', () {
    testWidgets('renders search box, category chips, and recipes list', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MealRepository();
      final mealProv = MealProvider(repository: repo, initDemoMeals: false);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: mealProv,
          child: const MaterialApp(home: RecipeSearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check Title
      expect(find.text('ค้นหาเมนู'), findsOneWidget);

      // Check Category Chips
      expect(find.text('ไก่'), findsOneWidget);
      expect(find.text('มังสวิรัติ'), findsWidgets);

      // Check Recipes loaded
      expect(find.text('ข้าวกะเพราเต้าหู้ไข่'), findsOneWidget);
      expect(find.text('สุกี้น้ำไก่'), findsOneWidget);

      // Type in search query
      await tester.enterText(find.byType(TextField), 'สุกี้');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Only สุกี้ should remain
      expect(find.text('สุกี้น้ำไก่'), findsOneWidget);
      expect(find.text('ข้าวกะเพราเต้าหู้ไข่'), findsNothing);
    });
  });
}
