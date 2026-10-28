import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/nutrition/presentation/nutrition_provider.dart';
import 'package:promkin_app/features/nutrition/presentation/widgets/macro_progress_bar.dart';

class NutritionDashboardScreen extends StatelessWidget {
  const NutritionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final settings = context.watch<SettingsProvider>();
    final nutritionProv = context.watch<NutritionProvider>();

    final summary = nutritionProv.calculateSummary(
      meals: mealProv.meals,
      targetCalories: settings.dailyCalories,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลโภชนาการวันนี้')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calories Main Ring/Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'พลังงานทั้งหมดที่ได้รับ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${summary.totalCalories}',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.calories,
                          ),
                        ),
                        Text(
                          ' / ${summary.targetCalories} kcal',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: summary.caloriesRatio,
                        minHeight: 14,
                        backgroundColor: AppColors.calories.withAlpha(40),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.calories,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Macronutrient details
            const Text(
              'สัดส่วนสารอาหารหลัก (Macronutrients)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    MacroProgressBar(
                      label: 'โปรตีน (Protein)',
                      current: summary.totalProtein,
                      target: summary.targetProtein,
                      unit: 'g',
                      color: AppColors.protein,
                    ),
                    const Divider(height: 24),
                    MacroProgressBar(
                      label: 'คาร์โบไฮเดรต (Carbohydrates)',
                      current: summary.totalCarbs,
                      target: summary.targetCarbs,
                      unit: 'g',
                      color: AppColors.carbs,
                    ),
                    const Divider(height: 24),
                    MacroProgressBar(
                      label: 'ไขมัน (Fat)',
                      current: summary.totalFat,
                      target: summary.targetFat,
                      unit: 'g',
                      color: AppColors.fat,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
