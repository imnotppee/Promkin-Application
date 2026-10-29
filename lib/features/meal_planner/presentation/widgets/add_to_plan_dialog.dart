import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';

/// Modal dialog to schedule a recipe or menu item into the weekly meal plan
class AddToPlanDialog extends StatefulWidget {
  final String recipeName;
  final String emoji;
  final double price;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String imageUrl;
  final String source;
  final String? sourceId;
  final MealProvider mealProvider;

  const AddToPlanDialog({
    super.key,
    required this.recipeName,
    required this.emoji,
    required this.price,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.imageUrl = '',
    this.source = 'ai',
    this.sourceId,
    required this.mealProvider,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String recipeName,
    required String emoji,
    required double price,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String imageUrl = '',
    String source = 'ai',
    String? sourceId,
    required MealProvider mealProvider,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddToPlanDialog(
        recipeName: recipeName,
        emoji: emoji,
        price: price,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        imageUrl: imageUrl,
        source: source,
        sourceId: sourceId,
        mealProvider: mealProvider,
      ),
    );
  }

  @override
  State<AddToPlanDialog> createState() => _AddToPlanDialogState();
}

class _AddToPlanDialogState extends State<AddToPlanDialog> {
  late DateTime _selectedDate;
  String _mealSlot = 'มื้อกลางวัน';
  String _time = '12:00';
  late final TextEditingController _priceController;
  String? _priceError;

  final List<String> _mealSlots = const [
    'มื้อเช้า',
    'มื้อกลางวัน',
    'มื้อเย็น',
    'ของว่าง',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.mealProvider.selectedDate;
    _priceController = TextEditingController(
      text: widget.price > 0 ? widget.price.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _onSlotChanged(String slot) {
    setState(() {
      _mealSlot = slot;
      if (slot == 'มื้อเช้า') _time = '07:30';
      if (slot == 'มื้อกลางวัน') _time = '12:00';
      if (slot == 'มื้อเย็น') _time = '18:30';
      if (slot == 'ของว่าง') _time = '15:30';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE d MMM', 'th_TH');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
          maxWidth: 520,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Food Icon
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6EDDF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เพิ่มเมนูลงในแผน',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.price > 0
                                ? '${widget.recipeName} · ฿${widget.price.toStringAsFixed(0)}'
                                : widget.recipeName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1ED),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: widget.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.imageUrl,
                                      width: 78,
                                      height: 78,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Text(
                                        widget.emoji,
                                        style: const TextStyle(fontSize: 38),
                                      ),
                                    ),
                                  )
                                : Text(
                                    widget.emoji,
                                    style: const TextStyle(fontSize: 38),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _badge(
                                      'มื้อที่เลือก',
                                      AppColors.primaryContainer,
                                    ),
                                    const SizedBox(width: 5),
                                    if (widget.price > 0)
                                      _badge(
                                        'ประมาณ ฿${widget.price.toStringAsFixed(0)}',
                                        AppColors.tertiaryContainer,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  widget.recipeName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.calories == null
                                      ? '◷  $_time น.  ·  ไม่มีข้อมูลแคลอรีจาก TheMealDB'
                                      : '◷  $_time น.  ·  🔥 ${widget.calories} kcal',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        children: [
                          _macroBadge(
                            'โปรตีน ${widget.protein?.toStringAsFixed(0) ?? '—'}g',
                          ),
                          const SizedBox(width: 5),
                          _macroBadge(
                            'คาร์บ ${widget.carbs?.toStringAsFixed(0) ?? '—'}g',
                          ),
                          const SizedBox(width: 5),
                          _macroBadge(
                            'ไขมัน ${widget.fat?.toStringAsFixed(0) ?? '—'}g',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) {
                    if (_priceError != null) setState(() => _priceError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'ราคาต่อมื้อ (บาท)',
                    hintText: 'กรอกราคาจริง',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    errorText: _priceError,
                  ),
                ),
                const SizedBox(height: 16),

                // Select Day
                const Text(
                  'เลือกวันที่',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFBFBF8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 35,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final selected = DateUtils.isSameDay(date, _selectedDate);
                      return ChoiceChip(
                        label: Text(
                          '${DateFormat('E', 'th_TH').format(date)} ${date.day}',
                        ),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedDate = date),
                        visualDensity: VisualDensity.compact,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.primary : AppColors.muted,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Select Slot
                const Text(
                  'เลือกมื้อ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _mealSlots.map((slot) {
                    final selected = _mealSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: selected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected ? AppColors.primary : AppColors.ink,
                      ),
                      onSelected: (val) {
                        if (val) _onSlotChanged(slot);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Select Time
                const Text(
                  'เวลา',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final parts = _time.split(':');
                    final current = TimeOfDay(
                      hour: int.tryParse(parts[0]) ?? 12,
                      minute:
                          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                    );
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: current,
                    );
                    if (picked != null) {
                      setState(() {
                        final h = picked.hour.toString().padLeft(2, '0');
                        final m = picked.minute.toString().padLeft(2, '0');
                        _time = '$h:$m';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFBFBF8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_time น.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final price = double.tryParse(_priceController.text);
                        if (price == null || price < 0) {
                          setState(() => _priceError = 'กรุณากรอกราคาต่อมื้อ');
                          return;
                        }
                        final dateStr = DateFormat(
                          'yyyy-MM-dd',
                        ).format(_selectedDate);
                        final newMeal = MealModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: widget.recipeName,
                          mealType: _mealSlot,
                          price: price,
                          calories: widget.calories ?? 0,
                          protein: widget.protein ?? 0,
                          carbs: widget.carbs ?? 0,
                          fat: widget.fat ?? 0,
                          date: dateStr,
                          emoji: widget.emoji,
                          time: _time,
                          tags: [_mealSlot, 'เพิ่มจากเมนู'],
                          imageUrl: widget.imageUrl,
                          source: widget.source,
                          sourceId: widget.sourceId,
                        );

                        await widget.mealProvider.addMeal(newMeal);
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'เพิ่ม ${widget.recipeName} ลงในแผนมื้ออาหารแล้ว',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('เพิ่มในแผน'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _macroBadge(String text) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
