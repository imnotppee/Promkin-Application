import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/add_meal_screen.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  DateTime _currentWeekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );
  DateTime? _selectedDayDetail;

  final List<String> _thaiDayNames = const [
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์',
  ];

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();

    if (_selectedDayDetail != null) {
      return _buildDayDetailView(context, mealProvider, _selectedDayDetail!);
    }

    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final weekRangeStr =
        '${DateFormat('d MMM', 'th_TH').format(_currentWeekStart)} – ${DateFormat('d MMM yyyy', 'th_TH').format(weekEnd)}';

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('วางแผนมื้ออาหาร'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.subtract(
                  const Duration(days: 7),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentWeekStart = _currentWeekStart.add(
                  const Duration(days: 7),
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Subtitle
            Row(
              children: [
                const Icon(
                  Icons.calendar_view_week,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'สัปดาห์นี้ · $weekRangeStr',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 7 Days List Card
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
                separatorBuilder: (_, index) =>
                    const Divider(height: 1, color: AppColors.line),
                itemBuilder: (ctx, i) {
                  final dayDate = _currentWeekStart.add(Duration(days: i));
                  final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
                  final dayMeals = mealProvider.meals
                      .where((m) => m.date == dateStr)
                      .toList();

                  final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                      dateStr;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${_thaiDayNames[i]} ${dayDate.day} ${DateFormat('MMM', 'th_TH').format(dayDate)}',
                          style: TextStyle(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.w600,
                            color: isToday ? AppColors.primary : AppColors.ink,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'วันนี้',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${dayMeals.length} มื้อที่วางแผนไว้',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDayDetail = dayDate;
                        });
                      },
                      child: const Text(
                        'ดูมื้ออาหาร',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDetailView(
    BuildContext context,
    MealProvider mealProvider,
    DateTime date,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dayMeals =
        mealProvider.meals.where((m) => m.date == dateStr).toList();
    final totalCalories = dayMeals.fold<int>(0, (a, b) => a + b.calories);
    final totalCost = dayMeals.fold<double>(0.0, (a, b) => a + b.price);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedDayDetail = null),
        ),
        title: Text(
          DateFormat('EEEE d MMMM', 'th_TH').format(date),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สรุปของวันนี้',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSummaryPill('🍽 ${dayMeals.length} มื้อ'),
                        const SizedBox(width: 8),
                        _buildSummaryPill('🔥 $totalCalories kcal'),
                        const SizedBox(width: 8),
                        _buildSummaryPill(
                          '฿ ${CurrencyFormatter.formatCompact(totalCost)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Meals List
            if (dayMeals.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  child: Center(
                    child: Text(
                      'วันนี้ยังไม่มีเมนูที่วางแผนไว้',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              )
            else
              ...dayMeals.map((m) => _buildMealDetailCard(m, mealProvider)),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('＋ เพิ่มเมนูในวันนี้'),
                onPressed: () {
                  mealProvider.setSelectedDate(date);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddMealScreen(date: date)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget _buildMealDetailCard(MealModel meal, MealProvider prov) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6EDDF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    meal.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${meal.mealType} · ${meal.time} น. · ${meal.calories} kcal',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(meal.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              const Divider(color: AppColors.line, height: 20),
              Text(
                meal.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

