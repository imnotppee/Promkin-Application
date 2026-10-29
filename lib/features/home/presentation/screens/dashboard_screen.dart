import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/widgets/promkin_header.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/ai_provider.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/add_to_plan_dialog.dart';
import 'package:promkin_app/features/recipe_search/presentation/screens/recipe_search_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;
  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _weekStart = _monday(DateTime.now());
  late DateTime _selectedDate = DateTime.now();

  DateTime _monday(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: date.weekday - 1));

  String _iso(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    final allMeals = context.watch<MealProvider>().allMeals;
    final mealProvider = context.read<MealProvider>();
    final ai = context.watch<AiProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'ผู้ใช้';
    final dayMeals =
        allMeals.where((meal) => meal.date == _iso(_selectedDate)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    final spent = dayMeals.fold<double>(0, (sum, meal) => sum + meal.price);
    final monthMeals = allMeals.where((meal) {
      final date = DateTime.tryParse(meal.date);
      return date?.month == DateTime.now().month &&
          date?.year == DateTime.now().year;
    }).toList();
    final monthSpent = monthMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.price,
    );
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final weekMeals = allMeals.where((meal) {
      final date = DateTime.tryParse(meal.date);
      return date != null &&
          !date.isBefore(_weekStart) &&
          !date.isAfter(weekEnd);
    }).toList();
    final budgetProgress = settings.monthlyBudget <= 0
        ? 0.0
        : (monthSpent / settings.monthlyBudget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => mealProvider.loadMealsForDate(_selectedDate),
          child: FadeSlideIn(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: PromkinHeader(showTune: false, showProfile: false),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'สวัสดี, $userName ☀️',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'วันนี้กินอะไรดี? วางแผนมื้ออร่อยและสบายกระเป๋ากัน',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _softPill('● วันนี้ตามเป้า'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _budgetCard(
                        context,
                        monthSpent,
                        settings.monthlyBudget,
                        budgetProgress,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              context,
                              Icons.checklist_rounded,
                              'มื้อที่วางแผนแล้ว',
                              '${weekMeals.length} / ${settings.mealsPerDay * 7} มื้อ',
                              'อัปเดตมื้ออาหารของคุณ',
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _metricCard(
                              context,
                              Icons.savings_outlined,
                              'ค่าเฉลี่ยต่อมื้อ',
                              '฿${monthMeals.isEmpty ? 0 : (monthSpent / monthMeals.length).round()}',
                              'งบวันนี้เหลือ ฿${(settings.dailyBudget - spent).round()}',
                              AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _weekSelector(allMeals),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ตารางมื้ออาหารวันนี้',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                          ),
                          _softPill(
                            DateFormat(
                              'EEEE d MMM',
                              'th_TH',
                            ).format(_selectedDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${dayMeals.length} มื้อที่วางแผน',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'ใช้ไป ฿${spent.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (dayMeals.isEmpty)
                        _emptyMeals(context)
                      else
                        ...dayMeals.map(_mealCard),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          mealProvider.setSelectedDate(_selectedDate);
                          final navigateToTab = widget.onNavigateToTab;
                          if (navigateToTab != null) {
                            navigateToTab(3);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecipeSearchScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มมื้ออาหารในวันนี้'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _aiRecommendationCard(ai, mealProvider, settings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _budgetCard(
    BuildContext context,
    double spent,
    double budget,
    double progress,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withAlpha(10),
          blurRadius: 20,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconTile(
              Icons.account_balance_wallet_outlined,
              AppColors.primaryContainer,
              AppColors.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'งบอาหารเดือนนี้',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            _softPill('เหลือ ฿${(budget - spent).round()}'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '฿${spent.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 7),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '/ ฿${budget.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFF0EEEA),
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  Widget _metricCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color accent,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withAlpha(8),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _weekSelector(List<MealModel> meals) {
    final end = _weekStart.add(const Duration(days: 6));
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  "${DateFormat('d MMM', 'th_TH').format(_weekStart)} - ${DateFormat('d MMM', 'th_TH').format(end)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              _calendarArrow(Icons.chevron_left_rounded, () => _changeWeek(-1)),
              const SizedBox(width: 2),
              _calendarArrow(Icons.chevron_right_rounded, () => _changeWeek(1)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: List.generate(7, (index) {
              final date = _weekStart.add(Duration(days: index));
              final selected = DateUtils.isSameDay(date, _selectedDate);
              final hasMeals = meals.any((meal) => meal.date == _iso(date));
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedDate = date);
                        context.read<MealProvider>().setSelectedDate(date);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 58,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEEEE', 'th_TH').format(date),
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d', 'th_TH').format(date),
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              height: 4,
                              child: hasMeals
                                  ? const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _calendarArrow(IconData icon, VoidCallback onPressed) => SizedBox(
    width: 30,
    height: 30,
    child: IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(foregroundColor: AppColors.muted),
    ),
  );

  void _changeWeek(int delta) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * delta));
      _selectedDate = _selectedDate.add(Duration(days: 7 * delta));
    });
    context.read<MealProvider>().setSelectedDate(_selectedDate);
  }

  Widget _mealCard(MealModel meal) {
    final completed = meal.isCompleted;
    final tint = meal.mealType.contains('เช้า')
        ? AppColors.tertiaryContainer
        : meal.mealType.contains('เย็น')
        ? const Color(0xFFE7EFE6)
        : const Color(0xFFF1F0EB);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(7),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: meal.imageUrl.isNotEmpty
                    ? Image.network(
                        meal.imageUrl,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _mealThumbnailFallback(meal, tint),
                      )
                    : _mealThumbnailFallback(meal, tint),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meal.mealType}  ·  ${meal.time} น.',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '🔥 ${meal.calories} kcal  ·  ฿${meal.price.toStringAsFixed(0)}  ·  โปรตีน ${meal.protein.toStringAsFixed(0)}g',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    if (meal.tags.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 5,
                        children: meal.tags.take(2).map(_softPill).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.muted),
                onSelected: (action) async {
                  final provider = context.read<MealProvider>();
                  if (action == 'toggle') {
                    await provider.toggleMealCompletion(meal);
                  }
                  if (action == 'delete') {
                    await provider.removeMeal(meal.id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      completed
                          ? 'ยกเลิกว่าทานแล้ว'
                          : 'ทำเครื่องหมายว่าทานแล้ว',
                    ),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('ลบจากแผน')),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          InkWell(
            onTap: () =>
                context.read<MealProvider>().toggleMealCompletion(meal),
            child: Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: completed ? AppColors.primary : AppColors.muted,
                ),
                const SizedBox(width: 8),
                Text(
                  completed
                      ? 'ทานแล้ว (บันทึกสำเร็จ)'
                      : 'ทำเครื่องหมายว่าทานแล้ว',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealThumbnailFallback(MealModel meal, Color tint) => Container(
    width: 62,
    height: 62,
    alignment: Alignment.center,
    color: tint,
    child: Text(meal.emoji, style: const TextStyle(fontSize: 27)),
  );

  Widget _emptyMeals(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.restaurant_menu_rounded,
          color: AppColors.secondary,
          size: 30,
        ),
        SizedBox(height: 8),
        Text(
          'วันนี้ยังไม่มีมื้ออาหารที่วางแผนไว้',
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _aiRecommendationCard(
    AiProvider ai,
    MealProvider mealProvider,
    SettingsProvider settings,
  ) {
    final menu = ai.dashboardPick;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0E7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.tertiary),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'AI แนะนำเมนูวันนี้',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'สุ่มเมนูใหม่',
                visualDensity: VisualDensity.compact,
                onPressed: ai.isDashboardPickLoading
                    ? null
                    : () => ai.fetchDashboardPick(
                        budget: settings.dailyBudget,
                        targetCalories: settings.dailyCalories,
                        mealCount: settings.mealsPerDay,
                        dislikedIngredients: settings.dislikedIngredients,
                        cuisines: settings.favoriteCuisines,
                      ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (ai.isDashboardPickLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text('กำลังเลือกเมนูให้เหมาะกับงบของคุณ…')),
                ],
              ),
            )
          else if (menu != null) ...[
            Text(
              menu.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              '${menu.mealType} · ${menu.calories} kcal · ฿${menu.estimatedPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              menu.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => AddToPlanDialog.show(
                  context,
                  recipeName: menu.name,
                  emoji: menu.mealType == 'มื้อเช้า'
                      ? '🍳'
                      : menu.mealType == 'มื้อเย็น'
                      ? '🍛'
                      : '🍜',
                  price: menu.estimatedPrice,
                  calories: menu.calories,
                  protein: menu.protein,
                  carbs: menu.carbs,
                  fat: menu.fat,
                  mealProvider: mealProvider,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('เพิ่มในแผนมื้ออาหาร'),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                ai.dashboardPickError ?? 'กำลังเตรียมเมนูแนะนำ…',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconTile(IconData icon, Color background, Color foreground) =>
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 19, color: foreground),
      );

  Widget _softPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE5EFE4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    ),
  );
}
