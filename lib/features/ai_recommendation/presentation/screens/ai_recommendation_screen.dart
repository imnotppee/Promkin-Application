import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/add_to_plan_dialog.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/ai_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/widgets/recommended_menu_card.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final TextEditingController _budgetCtrl = TextEditingController(text: '180');
  int _mealCount = 3;
  String _selectedGoal = 'สมดุล';
  final Set<String> _selectedCuisines = {'อาหารไทย'};

  final List<String> _cuisines = const [
    'อาหารไทย',
    'มังสวิรัติ',
    'คลีน',
    'ญี่ปุ่น',
  ];

  final List<String> _goals = const ['สมดุล', 'โปรตีนสูง', 'แคลอรีต่ำ'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAi();
    });
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _requestAi() {
    final budget = double.tryParse(_budgetCtrl.text) ?? 180.0;
    final settings = context.read<SettingsProvider>();
    context.read<AiProvider>().fetchRecommendations(
      budget: budget,
      targetCalories: settings.dailyCalories,
      mealCount: _mealCount,
      dislikedIngredients: settings.dislikedIngredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final mealProvider = context.read<MealProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
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
            // Preference Form Card (matching prototype)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ตั้งค่าเมนูแนะนำ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Budget Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('งบอาหารต่อวัน', style: TextStyle(fontSize: 13)),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _budgetCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              prefixText: '฿ ',
                              prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.line, height: 24),

                    // Meal Count Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('จำนวนมื้อ', style: TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: _mealCount,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 2, child: Text('2 มื้อ')),
                            DropdownMenuItem(value: 3, child: Text('3 มื้อ')),
                            DropdownMenuItem(value: 4, child: Text('4 มื้อ')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _mealCount = val);
                          },
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.line, height: 24),

                    // Cuisine Types
                    const Text(
                      'ประเภทอาหารที่ต้องการ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _cuisines.map((c) {
                        final isSel = _selectedCuisines.contains(c);
                        return FilterChip(
                          label: Text(c),
                          selected: isSel,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSel ? AppColors.primary : AppColors.ink,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCuisines.add(c);
                              } else {
                                if (_selectedCuisines.length > 1) {
                                  _selectedCuisines.remove(c);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Nutrition Goal
                    const Text(
                      'เป้าหมายโภชนาการ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _goals.map((g) {
                        final isSel = _selectedGoal == g;
                        return ChoiceChip(
                          label: Text(g),
                          selected: isSel,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSel ? AppColors.primary : AppColors.ink,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedGoal = g);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Text('✦', style: TextStyle(fontSize: 16)),
                        label: const Text('แนะนำเมนูให้ฉัน'),
                        onPressed: _requestAi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AI Results Section
            if (ai.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 14),
                      Text('AI กำลังวิเคราะห์และคัดเลือกเมนูที่เหมาะกับคุณ...'),
                    ],
                  ),
                ),
              )
            else if (ai.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(ai.errorMessage!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _requestAi,
                        child: const Text('ลองใหม่อีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'เมนูแนะนำสำหรับคุณ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${ai.recommendations.length} รายการ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...ai.recommendations.map(
                (menu) => RecommendedMenuCard(
                  item: menu,
                  onAdd: () {
                    AddToPlanDialog.show(
                      context,
                      recipeName: menu.name,
                      emoji: menu.mealType == 'มื้อเช้า'
                          ? '🍳'
                          : (menu.mealType == 'มื้อกลางวัน' ? '🍜' : '🍛'),
                      price: menu.estimatedPrice,
                      calories: menu.calories,
                      protein: menu.protein,
                      carbs: menu.carbs,
                      fat: menu.fat,
                      mealProvider: mealProvider,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
