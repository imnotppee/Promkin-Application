import 'package:flutter/material.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const MealCard({super.key, required this.meal, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: meal.isCompleted
            ? BorderSide(color: Colors.green.shade300, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Meal type indicator icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(meal.mealType),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Meal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meal.mealType,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.format(meal.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: meal.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildMacroBadge(
                        '${meal.calories} kcal',
                        AppColors.calories,
                      ),
                      _buildMacroBadge(
                        'P: ${meal.protein}g',
                        AppColors.protein,
                      ),
                      _buildMacroBadge('C: ${meal.carbs}g', AppColors.carbs),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: Icon(
                meal.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: meal.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: onToggle,
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _getMealIcon(String type) {
    switch (type) {
      case 'มื้อเช้า':
        return Icons.wb_sunny_outlined;
      case 'มื้อกลางวัน':
        return Icons.wb_cloudy_outlined;
      case 'มื้อเย็น':
        return Icons.nights_stay_outlined;
      default:
        return Icons.fastfood_outlined;
    }
  }
}
