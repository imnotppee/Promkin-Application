import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/constants/app_strings.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/home/presentation/screens/dashboard_screen.dart';
import 'package:promkin_app/features/meal_planner/presentation/screens/weekly_planner_screen.dart';
import 'package:promkin_app/features/ai_recommendation/presentation/screens/ai_recommendation_screen.dart';
import 'package:promkin_app/features/recipe_search/presentation/screens/recipe_search_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/screens/settings_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<SettingsProvider>().loadForUser(userId);
      }
    });
  }

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(onNavigateToTab: _onSelectTab),
      const WeeklyPlannerScreen(),
      const AiRecommendationScreen(),
      const RecipeSearchScreen(),
      const SettingsScreen(),
    ];
    final tabChildren = List<Widget>.generate(
      screens.length,
      (index) => _visitedTabs.contains(index)
          ? screens[index]
          : const SizedBox.shrink(),
    );

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabChildren),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: AppStrings.navHome,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                  label: 'วางแผนมื้อ',
                ),
                _buildAiCenterButton(),
                _buildNavItem(
                  index: 3,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book_rounded,
                  label: 'ค้นหาเมนู',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: AppStrings.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _onSelectTab(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiCenterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _onSelectTab(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 25,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: _currentIndex == 2
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: _currentIndex == 2 ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
