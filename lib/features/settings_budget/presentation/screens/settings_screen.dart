import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าระบบ & งบประมาณ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Budget Settings
          _buildSectionHeader('การจัดการงบประมาณและมื้ออาหาร'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.attach_money,
                    color: AppColors.primary,
                  ),
                  title: const Text('งบประมาณรายวัน'),
                  subtitle: Text(
                    CurrencyFormatter.format(settings.dailyBudget),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBudgetDialog(context, settings),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.calories,
                  ),
                  title: const Text('เป้าหมายแคลอรีต่อวัน'),
                  subtitle: Text('${settings.dailyCalories} kcal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCaloriesDialog(context, settings),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.restaurant,
                    color: AppColors.secondary,
                  ),
                  title: const Text('จำนวนมื้ออาหารต่อวัน'),
                  subtitle: Text('${settings.mealsPerDay} มื้อ'),
                  trailing: DropdownButton<int>(
                    value: settings.mealsPerDay,
                    underline: const SizedBox(),
                    items: [1, 2, 3, 4, 5].map((m) {
                      return DropdownMenuItem(value: m, child: Text('$m มื้อ'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) settings.updateMealsPerDay(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Preferences & Allergies
          _buildSectionHeader('ข้อจำกัดอาหาร / อาหารที่ไม่ต้องการ'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI จะหลีกเลี่ยงวัตถุดิบเหล่านี้ในการแนะนำเมนู:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...settings.dislikedIngredients.map(
                        (item) => Chip(
                          label: Text(item),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              settings.removeDislikedIngredient(item),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: const Text('เพิ่มวัตถุดิบ'),
                        onPressed: () =>
                            _showAddIngredientDialog(context, settings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Notification & App Settings
          _buildSectionHeader('การแจ้งเตือนและการแสดงผล'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('แจ้งเตือนเวลารับประทานอาหาร'),
                  subtitle: const Text('Meal Reminder'),
                  value: settings.isMealReminderEnabled,
                  onChanged: (val) => settings.toggleReminder(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('โหมดมืด (Dark Mode)'),
                  value: settings.isDarkMode,
                  onChanged: (val) => settings.toggleDarkMode(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.dailyBudget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('กำหนดงบประมาณรายวัน (บาท)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'งบประมาณ (บาท)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                settings.updateBudget(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showCaloriesDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.dailyCalories.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('กำหนดเป้าหมายแคลอรี (kcal)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'แคลอรี (kcal)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                settings.updateCalories(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showAddIngredientDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เพิ่มวัตถุดิบที่ไม่ต้องการ / แพ้'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'เช่น กุ้ง, ไข่, พริก'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                settings.addDislikedIngredient(text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }
}
