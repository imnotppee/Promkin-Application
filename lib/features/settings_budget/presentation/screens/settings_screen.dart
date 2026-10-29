import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/core/services/notification_service.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:promkin_app/features/settings_budget/presentation/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showMealPreferences = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        tooltip: 'ย้อนกลับ',
                        onPressed:
                            widget.onBack ?? () => Navigator.maybePop(context),
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
                      'จัดการบัญชีและการตั้งค่าการใช้งาน',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    _settingsTabs(),
                    const SizedBox(height: 16),
                    if (_showMealPreferences)
                      _mealSettings(settings)
                    else
                      _accountSettings(
                        user?.name ?? 'ผู้ใช้ PromKin',
                        user?.email ?? 'โปรไฟล์ PROM KIN',
                      ),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('บันทึกการตั้งค่าแล้ว'),
                            ),
                          ),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('บันทึกการตั้งค่า'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
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

  Widget _settingsTabs() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF2EFEB),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _settingsTab('แอป & บัญชี', Icons.tune_rounded, false),
        _settingsTab('แผนอาหาร', Icons.restaurant_menu_rounded, true),
      ],
    ),
  );

  Widget _settingsTab(String label, IconData icon, bool mealPreferences) {
    final selected = _showMealPreferences == mealPreferences;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _showMealPreferences = mealPreferences),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountSettings(String name, String subtitle) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
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
        _settingField('ไทย (Thai)', Icons.language),
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
            _themeModeLabel(settings.themeMode),
            Icons.expand_more,
            onTap: () => _chooseThemeMode(settings),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Material(
      color: Colors.transparent,
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
              suffix: 'บาท / วัน',
              allowDecimal: true,
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
              suffix: 'บาท / เดือน',
              allowDecimal: true,
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
              suffix: 'kcal / วัน',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.restaurant_menu,
              color: AppColors.primary,
            ),
            title: const Text('จำนวนมื้ออาหารต่อวัน'),
            trailing: DropdownButton<int>(
              value: settings.mealsPerDay,
              underline: const SizedBox(),
              items: [1, 2, 3, 4, 5]
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('$v มื้อ')),
                  )
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
            onChanged: (value) async {
              final messenger = ScaffoldMessenger.of(context);
              final enabled = await settings.toggleReminder(value);
              if (!enabled && mounted) {
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'กรุณาอนุญาตการแจ้งเตือนในการตั้งค่าอุปกรณ์',
                      ),
                    ),
                  );
              } else if (value &&
                  mounted &&
                  !await NotificationService.instance
                      .canScheduleExactReminders()) {
                if (!mounted) return;
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'ยังไม่ได้อนุญาต “ตั้งปลุกและการเตือนความจำ” '
                        'การแจ้งเตือนอาจคลาดเคลื่อน',
                      ),
                    ),
                  );
              }
            },
          ),
        ],
      ),
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
    Future<void> Function(String) save, {
    required String suffix,
    bool allowDecimal = false,
  }) async {
    var inputValue = initial;
    String? validationError;
    final valueToSave = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextFormField(
            initialValue: initial,
            keyboardType: TextInputType.numberWithOptions(
              decimal: allowDecimal,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
              ),
            ],
            decoration: InputDecoration(
              suffixText: suffix,
              errorText: validationError,
            ),
            onChanged: (value) {
              inputValue = value;
              if (validationError != null) {
                setDialogState(() => validationError = null);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = inputValue.trim();
                final parsed = allowDecimal
                    ? double.tryParse(value)
                    : int.tryParse(value)?.toDouble();
                if (parsed == null || !parsed.isFinite || parsed <= 0) {
                  setDialogState(
                    () => validationError = allowDecimal
                        ? 'กรอกตัวเลขที่มากกว่า 0'
                        : 'กรอกจำนวนเต็มที่มากกว่า 0',
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );

    // Persist after the dialog route has fully closed. Updating SettingsProvider
    // while the dialog is still in the Navigator overlay can deactivate an
    // inherited element while the dialog's dependents are being torn down.
    if (valueToSave == null || !mounted) return;
    try {
      await save(valueToSave);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('บันทึกค่าเรียบร้อย')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('บันทึกไม่สำเร็จ กรุณาลองอีกครั้ง')),
        );
    }
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'โหมดสว่าง (Light)',
    ThemeMode.dark => 'โหมดมืด (Dark)',
    _ => 'ตามอุปกรณ์ (System default)',
  };

  Future<void> _chooseThemeMode(SettingsProvider settings) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('รูปแบบการแสดงผล'),
        children: [
          for (final mode in ThemeMode.values)
            ListTile(
              leading: Icon(
                settings.themeMode == mode
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: settings.themeMode == mode
                    ? Theme.of(dialogContext).colorScheme.primary
                    : null,
              ),
              title: Text(_themeModeLabel(mode)),
              onTap: () => Navigator.pop(dialogContext, mode),
            ),
        ],
      ),
    );
    if (selected != null) await settings.setThemeMode(selected);
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
