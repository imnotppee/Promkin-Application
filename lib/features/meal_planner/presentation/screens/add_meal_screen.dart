import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/utils/date_formatter.dart';
import 'package:promkin_app/features/meal_planner/data/meal_model.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime date;

  const AddMealScreen({super.key, required this.date});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');

  String _selectedMealType = 'มื้อเช้า';
  final List<String> _mealTypes = [
    'มื้อเช้า',
    'มื้อกลางวัน',
    'มื้อเย็น',
    'ของว่าง',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      final newMeal = MealModel(
        id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        mealType: _selectedMealType,
        price: double.tryParse(_priceController.text) ?? 0.0,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        carbs: double.tryParse(_carbsController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        date: DateFormatter.toIso(widget.date),
      );

      context.read<MealProvider>().addMeal(newMeal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มมื้ออาหาร')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedMealType,
                decoration: const InputDecoration(labelText: 'ประเภทมื้อ'),
                items: _mealTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMealType = val);
                },
              ),
              const SizedBox(height: 16),

              // Meal Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเมนูอาหาร *',
                  hintText: 'เช่น ข้าวผัดไข่, สลัดไก่',
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'กรุณาระบุชื่อเมนูอาหาร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price & Calories row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ราคา (บาท) *',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'กรุณาระบุราคา';
                        if (double.tryParse(val) == null)
                          return 'ตัวเลขไม่ถูกต้อง';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'แคลอรี (kcal) *',
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'กรุณาระบุแคลอรี';
                        if (int.tryParse(val) == null)
                          return 'ตัวเลขไม่ถูกต้อง';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Macros Section Header
              const Text(
                'สารอาหารหลัก (มาโครนิวเทรียนท์ - ไม่บังคับ)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'โปรตีน (g)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'คาร์บ (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'ไขมัน (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึกมื้ออาหาร'),
                onPressed: _saveMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
