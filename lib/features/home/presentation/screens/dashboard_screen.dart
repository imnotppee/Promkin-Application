import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/add_meal_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDayIndex = 1; // Default to Tuesday as in prototype
  int _weekOffset = 0;

  final List<String> _dayNames = const [
    'จ.',
    'อ.',
    'พ.',
    'พฤ.',
    'ศ.',
    'ส.',
    'อา.',
  ];

  DateTime _getDateForDayIndex(int index) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _weekOffset * 7 + index));
  }

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final selectedDate = _getDateForDayIndex(_selectedDayIndex);
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final mealsForSelectedDay = mealProv.meals
        .where((m) => m.date == selectedDateStr)
        .toList();

    final monthlyBudget = settingsProv.monthlyBudget;
    final totalSpentThisMonth = mealProv.meals.fold<double>(
      0.0,
      (sum, m) => sum + m.price,
    );
    final budgetProgress = monthlyBudget > 0
        ? (totalSpentThisMonth / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final remainingMonthly = monthlyBudget - totalSpentThisMonth;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => mealProv.loadMealsForDate(mealProv.selectedDate),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topbar & Greeting
                _buildHeader(context, selectedDate),
                const SizedBox(height: 18),

                // 3 Metric Cards Overview
                _buildOverviewMetrics(
                  monthlyBudget: monthlyBudget,
                  spent: totalSpentThisMonth,
                  remaining: remainingMonthly,
                  progress: budgetProgress,
                  mealsCount: mealProv.meals.length,
                ),
                const SizedBox(height: 20),

                // Week Calendar Card with Day Selector & Meals
                _buildWeeklyCard(context, mealProv, mealsForSelectedDay),
                const SizedBox(height: 20),

                // AI Highlight Banner Card
                _buildAiRecommendationBanner(
                  context,
                  mealProv,
                  selectedDateStr,
                ),
                const SizedBox(height: 18),

                // Today's Nutrition Summary Card
                _buildNutritionSummaryCard(
                  context,
                  mealsForSelectedDay,
                  settingsProv,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime selectedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFDC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🥬', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    text: 'PROM ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'KIN',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(4); // Switch to Settings tab
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 18,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMM yyyy', 'th_TH').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              'สวัสดี, พิมพ์ชนก ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
            Text('☀️', style: TextStyle(fontSize: 22)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'วันนี้กินอะไรดี? วางแผนมื้ออร่อยและสบายกระเป๋ากัน',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildOverviewMetrics({
    required double monthlyBudget,
    required double spent,
    required double remaining,
    required double progress,
    required int mealsCount,
  }) {
    final avgCost = mealsCount > 0 ? (spent / mealsCount).round() : 68;

    return Column(
      children: [
        // Card 1: Budget (Full width)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'งบอาหารเดือนนี้',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🪙', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.formatCompact(spent),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${CurrencyFormatter.formatCompact(monthlyBudget)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E5D9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เหลือ ${CurrencyFormatter.formatCompact(remaining)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Row of Card 2 & Card 3
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'มื้อที่วางแผนแล้ว',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          Text('🍱', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: '$mealsCount ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                          children: const [
                            TextSpan(
                              text: '/ 21 มื้อ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'สัปดาห์นี้ · ทำได้ดีมาก!',
                        style: TextStyle(fontSize: 9, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ค่าเฉลี่ยต่อมื้อ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          Text('🌱', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '฿$avgCost',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ประหยัดกว่าก่อน 12%',
                        style: TextStyle(fontSize: 9, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyCard(
    BuildContext context,
    MealProvider mealProv,
    List<MealModel> dayMeals,
  ) {
    final startOfWeek = _getDateForDayIndex(0);
    final endOfWeek = _getDateForDayIndex(6);
    final weekRangeStr =
        '${startOfWeek.day} ${DateFormat('MMM', 'th_TH').format(startOfWeek)} – ${endOfWeek.day} ${DateFormat('MMM', 'th_TH').format(endOfWeek)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar with Date range & Prev/Next arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'แผนมื้ออาหาร',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          weekRangeStr,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _weekOffset--;
                        });
                        mealProv.setSelectedDate(
                          _getDateForDayIndex(_selectedDayIndex),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '‹',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _weekOffset++;
                        });
                        mealProv.setSelectedDate(
                          _getDateForDayIndex(_selectedDayIndex),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '›',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(1); // Switch to Planner tab
                        }
                      },
                      child: const Text(
                        'ดูทั้งหมด ›',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 7 Days Selector Bar
            Row(
              children: List.generate(7, (i) {
                final isSelected = _selectedDayIndex == i;
                final dayDate = _getDateForDayIndex(i);
                final isToday =
                    DateTime.now().day == dayDate.day &&
                    DateTime.now().month == dayDate.month;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = i;
                      });
                      mealProv.setSelectedDate(dayDate);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEAF0E6)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE2EADC)
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayNames[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dayDate.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.ink,
                            ),
                          ),
                          if (isToday && !isSelected) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE99A6B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Meals List for Selected Day
            if (dayMeals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: const Text(
                  'ยังไม่มีมื้ออาหารในวันนี้',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              )
            else
              ...dayMeals.map((m) => _buildMealRow(m, mealProv)),

            const SizedBox(height: 12),

            // Add Meal Button
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final targetDate = _getDateForDayIndex(_selectedDayIndex);
                mealProv.setSelectedDate(targetDate);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddMealScreen(date: targetDate),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD9DDCF),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '＋ เพิ่มเมนูมื้อถัดไป',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(MealModel meal, MealProvider prov) {
    Color emojiBg = const Color(0xFFF3E8D8);
    if (meal.mealType == 'มื้อกลางวัน') emojiBg = const Color(0xFFE6EFE0);
    if (meal.mealType == 'มื้อเย็น') emojiBg = const Color(0xFFF8E8DD);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF8),
        border: Border.all(color: const Color(0xFFF0F0EA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              meal.time,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: emojiBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(meal.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meal.notes!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: meal.tags.map((t) {
                    final isOrange =
                        t.contains('แนะนำ') || t.contains('มังสวิรัติ');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOrange
                            ? const Color(0xFFFFF0E6)
                            : const Color(0xFFF0F2E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 9,
                          color: isOrange
                              ? const Color(0xFFB5774D)
                              : const Color(0xFF68745E),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'kcal · ฿${meal.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationBanner(
    BuildContext context,
    MealProvider mealProv,
    String selectedDateStr,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E5CE),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '✦',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI เมนูแนะนำ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'อร่อยครบ จบในงบ 🌿',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'เลือกเมนูที่เหมาะกับงบและสไตล์การกินของคุณในวันนี้',
            style: TextStyle(fontSize: 11, color: Color(0xFF778171)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterBadge('฿ ไม่เกิน 80 บาท'),
              const SizedBox(width: 6),
              _buildFilterBadge('🥗 ไทย'),
              const SizedBox(width: 6),
              _buildFilterBadge('⚡ ทำง่าย'),
            ],
          ),
          const SizedBox(height: 14),

          // Recommended item card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0DD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🍛', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ข้าวกะเพราเต้าหู้ไข่',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ทำง่าย · 20 นาที · 380 kcal',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '฿45',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        final newMeal = MealModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: 'ข้าวกะเพราเต้าหู้ไข่',
                          mealType: 'มื้อเย็น',
                          price: 45.0,
                          calories: 380,
                          protein: 18.0,
                          carbs: 52.0,
                          fat: 10.0,
                          date: selectedDateStr,
                          emoji: '🍛',
                          time: '18:30',
                          tags: ['มังสวิรัติ', 'AI แนะนำ'],
                        );
                        mealProv.addMeal(newMeal);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'เพิ่มข้าวกะเพราเต้าหู้ไข่ในแผนแล้ว!',
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'เพิ่มในแผน +',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F1),
        border: Border.all(color: const Color(0xFFD9E3D0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF61745A)),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(
    BuildContext context,
    List<MealModel> meals,
    SettingsProvider settings,
  ) {
    final totalCalories = meals.fold<int>(0, (a, b) => a + b.calories);
    final totalProtein = meals.fold<double>(0.0, (a, b) => a + b.protein);
    final totalCarbs = meals.fold<double>(0.0, (a, b) => a + b.carbs);
    final totalFat = meals.fold<double>(0.0, (a, b) => a + b.fat);

    final targetCalories = settings.dailyCalories;
    final calorieRatio = targetCalories > 0
        ? (totalCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'โภชนาการวันนี้',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(4); // Settings tab
                    }
                  },
                  child: const Text(
                    'เป้าหมายรายวัน ⌄',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: '$totalCalories ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                    children: const [
                      TextSpan(
                        text: 'kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'จาก $targetCalories kcal',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: calorieRatio,
                minHeight: 6,
                backgroundColor: const Color(0xFFF0F0E9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFD9A65F),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMacroCol(
                  'โปรตีน',
                  '${totalProtein.toInt()} / 90 ก.',
                  const Color(0xFF9BB184),
                ),
                _buildMacroCol(
                  'คาร์บ',
                  '${totalCarbs.toInt()} / 250 ก.',
                  const Color(0xFFE6AD7D),
                ),
                _buildMacroCol(
                  'ไขมัน',
                  '${totalFat.toInt()} / 65 ก.',
                  const Color(0xFFD7C16F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCol(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 2.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
