import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/widgets/promkin_header.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';
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
      goal: _selectedGoal,
      cuisines: _selectedCuisines.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final mealProvider = context.read<MealProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: FadeSlideIn(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PromkinHeader(
                  onTune: _requestAi,
                  onProfile: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    '✦  SOUS-CHEF INTELLIGENCE',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI แนะนำเมนู',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'เลือกงบ จำนวนมื้อ และสไตล์อาหารที่ต้องการ',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                // Preference Form Card (matching prototype)
                Card(
                  color: const Color(0xFFF3F1ED),
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
                          children: [
                            const Expanded(
                              child: Text(
                                'งบอาหารต่อวัน (บาท)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              'ประหยัดคุ้มค่า',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _budgetCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '฿  ',
                            prefixStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Meal Count Row
                        const Text(
                          'จำนวนมื้อต่อวัน',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<int>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: 2, label: Text('2 มื้อ')),
                              ButtonSegment(value: 3, label: Text('3 มื้อ')),
                              ButtonSegment(value: 4, label: Text('4 มื้อ')),
                            ],
                            selected: {_mealCount},
                            onSelectionChanged: (value) =>
                                setState(() => _mealCount = value.first),
                          ),
                        ),
                        const Divider(color: AppColors.line, height: 24),

                        // Cuisine Types
                        const Text(
                          'ประเภทอาหารที่ต้องการ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.ink,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = 0; i < _goals.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _goalCard(
                                  _goals[i],
                                  [
                                    Icons.balance,
                                    Icons.fitness_center,
                                    Icons.local_fire_department_outlined,
                                  ][i],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Text(
                              '✦',
                              style: TextStyle(fontSize: 16),
                            ),
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
                          Text(
                            'AI กำลังวิเคราะห์และคัดเลือกเมนูที่เหมาะกับคุณ...',
                          ),
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
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: Colors.red,
                          ),
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
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.smart_toy_outlined, size: 16),
                    label: Text(_sourceLabel(ai.recommendationSource)),
                    visualDensity: VisualDensity.compact,
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
        ),
      ),
    );
  }

  String _sourceLabel(String source) {
    if (source.startsWith('openai-')) return 'OpenAI ${source.substring(7)}';
    if (source.startsWith('gemini')) return 'Gemini AI';
    if (source == 'rule-based-ai') return 'Backend recommendations';
    if (source == 'local-fallback') return 'Offline recommendations';
    return 'AI recommendations';
  }

  Widget _goalCard(String goal, IconData icon) {
    final selected = _selectedGoal == goal;
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(13),
      onTap: () => setState(() => _selectedGoal = goal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 76,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD5E6D5) : Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 21),
            const SizedBox(height: 5),
            Text(
              goal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
