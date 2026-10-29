import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/widgets/promkin_header.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/add_meal_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/screens/settings_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});
  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  DateTime _monday(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
  String _iso(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();
    final settings = context.watch<SettingsProvider>();
    final selectedDate = provider.selectedDate;
    final weekStart = _monday(selectedDate);
    final selectedMeals =
        provider.allMeals.where((m) => m.date == _iso(selectedDate)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekMeals = provider.allMeals
        .where(
          (m) =>
              m.date.compareTo(_iso(weekStart)) >= 0 &&
              m.date.compareTo(_iso(weekEnd)) <= 0,
        )
        .toList();
    final spend = selectedMeals.fold<double>(0, (sum, m) => sum + m.price);
    final calories = selectedMeals.fold<int>(0, (sum, m) => sum + m.calories);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: FadeSlideIn(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PromkinHeader(
                  onTune: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  onProfile: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'แผนมื้ออาหาร',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'จัดมื้อประจำสัปดาห์ให้พอดีกับงบของคุณ',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _weekToolbar(weekStart, weekEnd),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ภาพรวม 7 วัน',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _pill(
                          'แผนสำเร็จ ${weekMeals.length}/${settings.mealsPerDay * 7} มื้อ',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final date = weekStart.add(Duration(days: index));
                          final meals = provider.allMeals
                              .where((m) => m.date == _iso(date))
                              .toList();
                          final isSelected = DateUtils.isSameDay(
                            date,
                            selectedDate,
                          );
                          final isToday = DateUtils.isSameDay(
                            date,
                            DateTime.now(),
                          );
                          return SizedBox(
                            width: 138,
                            child: Material(
                              color: isSelected
                                  ? const Color(0xFFB3C2AE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _selectDate(date),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              DateFormat(
                                                'EEEE',
                                                'th_TH',
                                              ).format(date),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'd MMM',
                                              'th_TH',
                                            ).format(date),
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(
                                            isSelected ? 210 : 235,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 15,
                                              ),
                                            Text(
                                              '${meals.length} มื้อ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              meals.isEmpty
                                                  ? 'วางแผนไว้'
                                                  : 'ครบวันนี้',
                                              style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 33,
                                        child: OutlinedButton(
                                          onPressed: () => _selectDate(date),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: isSelected
                                                ? Colors.white
                                                : const Color(0xFFF4F2EE),
                                            padding: EdgeInsets.zero,
                                            side: BorderSide.none,
                                          ),
                                          child: Text(
                                            isSelected
                                                ? 'เลือกอยู่'
                                                : 'ดูมื้ออาหาร',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isToday) const SizedBox(height: 3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'มื้ออาหารวัน${DateFormat('EEEE d MMM', 'th_TH').format(selectedDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Text(
                          'งบรายวัน ฿${settings.dailyBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _summary(
                            Icons.restaurant_menu,
                            'มื้ออาหาร',
                            '${selectedMeals.length} มื้อ',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summary(
                            Icons.local_fire_department_outlined,
                            'แคลอรี',
                            '$calories kcal',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summary(
                            Icons.account_balance_wallet_outlined,
                            'ใช้ไปแล้ว',
                            '฿${spend.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (selectedMeals.isEmpty)
                      _empty()
                    else
                      ...selectedMeals.map(_mealCard),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addMeal,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มเมนูลงในแผน'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(DateTime date) {
    context.read<MealProvider>().setSelectedDate(date);
  }

  void _changeWeek(int amount) {
    final provider = context.read<MealProvider>();
    provider.setSelectedDate(
      provider.selectedDate.add(Duration(days: amount * 7)),
    );
  }

  void _addMeal() {
    final provider = context.read<MealProvider>();
    final selectedDate = provider.selectedDate;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMealScreen(date: selectedDate)),
    );
  }

  Widget _weekToolbar(DateTime start, DateTime end) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F1ED),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        _roundButton(Icons.chevron_left_rounded, () => _changeWeek(-1)),
        const Icon(
          Icons.calendar_month_outlined,
          color: AppColors.tertiary,
          size: 19,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '${DateFormat('d MMM', 'th_TH').format(start)} – ${DateFormat('d MMM yyyy', 'th_TH').format(end)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        _roundButton(Icons.chevron_right_rounded, () => _changeWeek(1)),
      ],
    ),
  );

  Widget _roundButton(IconData icon, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      fixedSize: const Size(38, 38),
    ),
  );

  Widget _summary(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.tertiary),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _mealThumbnailFallback(MealModel meal) => Container(
    width: 58,
    height: 58,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.breakfastBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(meal.emoji, style: const TextStyle(fontSize: 24)),
  );

  Widget _mealCard(MealModel meal) => Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: meal.imageUrl.isNotEmpty
                  ? Image.network(
                      meal.imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _mealThumbnailFallback(meal),
                    )
                  : _mealThumbnailFallback(meal),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.mealType}  ·  ${meal.time} น.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '฿${meal.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'done') {
                  context.read<MealProvider>().toggleMealCompletion(meal);
                }
                if (value == 'delete') {
                  context.read<MealProvider>().removeMeal(meal.id);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'done',
                  child: Text(meal.isCompleted ? 'ยกเลิกทานแล้ว' : 'ทานแล้ว'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('ลบมื้ออาหาร'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1ED),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(meal.emoji, style: const TextStyle(fontSize: 33)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 ${meal.calories} kcal  ·  โปรตีน ${meal.protein.toStringAsFixed(0)}g',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (meal.tags.isNotEmpty)
                    Wrap(
                      spacing: 5,
                      children: meal.tags.take(2).map(_pill).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 17),
        InkWell(
          onTap: () => context.read<MealProvider>().toggleMealCompletion(meal),
          child: Row(
            children: [
              Icon(
                meal.isCompleted
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: meal.isCompleted ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 7),
              Text(
                meal.isCompleted
                    ? 'ทานแล้ว (บันทึกสำเร็จ)'
                    : 'ทำเครื่องหมายว่าทานแล้ว',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _empty() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Column(
      children: [
        Icon(Icons.menu_book_outlined, color: AppColors.secondary, size: 30),
        SizedBox(height: 8),
        Text(
          'วันนี้ยังไม่มีมื้ออาหารที่วางแผนไว้',
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    ),
  );
  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE3EEE2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
