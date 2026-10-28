import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/core/utils/date_formatter.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/ai_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/widgets/recommended_menu_card.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAi();
    });
  }

  void _requestAi() {
    final settings = context.read<SettingsProvider>();
    context.read<AiProvider>().fetchRecommendations(
      budget: settings.dailyBudget,
      targetCalories: settings.dailyCalories,
      mealCount: settings.mealsPerDay,
      dislikedIngredients: settings.dislikedIngredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI แนะนำเมนูอาหาร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _requestAi,
            tooltip: 'สร้างคำแนะนำใหม่',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Info Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withAlpha(128),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 36,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'เงื่อนไขการแนะนำโดย AI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'งบประมาณ: ${CurrencyFormatter.format(settings.dailyBudget)} | แคลอรี: ${settings.dailyCalories} kcal | ${settings.mealsPerDay} มื้อ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (ai.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('AI กำลังวิเคราะห์และคัดเลือกเมนูที่เหมาะกับคุณ...'),
                    ],
                  ),
                ),
              )
            else if (ai.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(ai.errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _requestAi,
                        child: const Text('ลองใหม่อีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'เมนูแนะนำสำหรับคุณวันนี้',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('สุ่มใหม่'),
                        onPressed: _requestAi,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...ai.recommendations.map(
                    (menu) => RecommendedMenuCard(
                      item: menu,
                      onAdd: () {
                        final newMeal = MealModel(
                          id: 'ai_meal_${DateTime.now().millisecondsSinceEpoch}_${menu.name.hashCode}',
                          name: menu.name,
                          mealType: menu.mealType,
                          price: menu.estimatedPrice,
                          calories: menu.calories,
                          protein: menu.protein,
                          carbs: menu.carbs,
                          fat: menu.fat,
                          date: DateFormatter.toIso(DateTime.now()),
                        );
                        context.read<MealProvider>().addMeal(newMeal);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'เพิ่ม "${menu.name}" ลงในแผนอาหารแล้ว!',
                            ),
                            backgroundColor: AppColors.secondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
