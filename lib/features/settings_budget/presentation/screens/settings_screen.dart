import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: FadeSlideIn(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.person_outline),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList.list(
                  children: [
                    const Text(
                      'จัดการบัญชีผู้ใช้และการตั้งค่าแผนอาหาร',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F0EC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          _tabButton('☷  แอป & บัญชี', 0),
                          _tabButton('⚒  แผนอาหาร', 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_section == 0)
                      _accountSettings(
                        user?.name ?? 'พิมพ์ชนก',
                        user?.email ?? 'โปรไฟล์ PROM KIN',
                      )
                    else
                      _mealSettings(settings),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        'PROM KIN · 1.0 (Build 2024.1)\nMindful Daily Culinary Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted.withAlpha(180),
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('บันทึกการตั้งค่าแล้ว'),
                            ),
                          ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('บันทึกการตั้งค่า'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB2C1AD),
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(52),
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

  Widget _tabButton(String label, int index) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _section = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _section == index ? AppColors.paper : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _section == index ? AppColors.ink : AppColors.muted,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );

  Widget _accountSettings(String name, String subtitle) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
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
            const CircleAvatar(
              radius: 29,
              backgroundColor: AppColors.tertiaryContainer,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 31,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified, color: AppColors.tertiary),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'ชื่อที่แสดง',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        _settingField(
          name,
          Icons.edit_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'ภาษา (Language)',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        _settingField(
          'ไทย (Thai)',
          Icons.expand_more,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('รองรับภาษาไทยในแอปนี้')),
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'รูปแบบการแสดงผล',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Consumer<SettingsProvider>(
          builder: (context, settings, _) => _settingField(
            settings.isDarkMode
                ? 'โหมดมืด (Dark)'
                : 'ตามอุปกรณ์ (System default)',
            Icons.expand_more,
            onTap: () => settings.toggleDarkMode(!settings.isDarkMode),
          ),
        ),
      ],
    ),
  );

  Widget _settingField(String text, IconData icon, {VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F2EE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(icon, color: AppColors.muted, size: 19),
            ],
          ),
        ),
      );

  Widget _mealSettings(SettingsProvider settings) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'งบประมาณและเป้าหมาย',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _actionTile(
          Icons.account_balance_wallet_outlined,
          'งบประมาณรายวัน',
          CurrencyFormatter.format(settings.dailyBudget),
          () => _editNumber(
            'งบประมาณรายวัน (บาท)',
            settings.dailyBudget.toStringAsFixed(0),
            (v) => settings.updateBudget(double.parse(v)),
          ),
        ),
        _actionTile(
          Icons.calendar_month_outlined,
          'งบประมาณต่อเดือน',
          CurrencyFormatter.format(settings.monthlyBudget),
          () => _editNumber(
            'งบประมาณรายเดือน (บาท)',
            settings.monthlyBudget.toStringAsFixed(0),
            (v) => settings.updateMonthlyBudget(double.parse(v)),
          ),
        ),
        _actionTile(
          Icons.local_fire_department_outlined,
          'เป้าหมายแคลอรีต่อวัน',
          '${settings.dailyCalories} kcal',
          () => _editNumber(
            'เป้าหมายแคลอรี (kcal)',
            settings.dailyCalories.toString(),
            (v) => settings.updateCalories(int.parse(v)),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
          title: const Text('จำนวนมื้ออาหารต่อวัน'),
          trailing: DropdownButton<int>(
            value: settings.mealsPerDay,
            underline: const SizedBox(),
            items: [1, 2, 3, 4, 5]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v มื้อ')))
                .toList(),
            onChanged: (v) {
              if (v != null) settings.updateMealsPerDay(v);
            },
          ),
        ),
        const Divider(),
        const Text(
          'วัตถุดิบที่ไม่ต้องการ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          children: [
            ...settings.dislikedIngredients.map(
              (v) => InputChip(
                label: Text(v),
                onDeleted: () => settings.removeDislikedIngredient(v),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('เพิ่มวัตถุดิบ'),
              onPressed: () => _addIngredient(settings),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('แจ้งเตือนมื้ออาหาร'),
          value: settings.isMealReminderEnabled,
          onChanged: settings.toggleReminder,
        ),
      ],
    ),
  );

  Widget _actionTile(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    subtitle: Text(value),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );

  Future<void> _editNumber(
    String title,
    String initial,
    Future<void> Function(String) save,
  ) async {
    final controller = TextEditingController(text: initial);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'บาท / วัน'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty && double.tryParse(value) != null) {
                await save(value);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _addIngredient(SettingsProvider settings) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เพิ่มวัตถุดิบที่ไม่ต้องการ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'เช่น กุ้ง, ถั่วลิสง'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.addDislikedIngredient(controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
