import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/add_to_plan_dialog.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_model.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';

  final List<String> _categories = const [
    'ทั้งหมด',
    'อาหารไทย',
    'มังสวิรัติ',
    'โปรตีนสูง',
    'คลีน',
  ];

  final List<RecipeModel> _catalog = const [
    RecipeModel(
      id: 'rec_1',
      emoji: '🍛',
      name: 'ข้าวกะเพราเต้าหู้ไข่',
      category: 'มังสวิรัติ',
      cookingMinutes: 20,
      calories: 380,
      estimatedPrice: 45.0,
      description: 'เต้าหู้ไข่ · กะเพรา · ข้าวกล้อง · ทำง่าย อิ่มสบาย',
      tags: ['มังสวิรัติ', 'ทำง่าย'],
      protein: 18.0,
      carbs: 52.0,
      fat: 10.0,
    ),
    RecipeModel(
      id: 'rec_2',
      emoji: '🍜',
      name: 'ก๋วยเตี๋ยวต้มยำหมู',
      category: 'อาหารไทย',
      cookingMinutes: 25,
      calories: 480,
      estimatedPrice: 55.0,
      description: 'หมูสับ · เส้นเล็ก · ถั่วลิสง · มะนาวแท้',
      tags: ['อาหารไทย', 'รสแซ่บ'],
      protein: 24.0,
      carbs: 62.0,
      fat: 14.0,
    ),
    RecipeModel(
      id: 'rec_3',
      emoji: '🍲',
      name: 'สุกี้น้ำไก่',
      category: 'โปรตีนสูง',
      cookingMinutes: 20,
      calories: 360,
      estimatedPrice: 50.0,
      description: 'อกไก่ · ผักกาดขาว · วุ้นเส้น · น้ำจิ้มเต้าหู้ยี้',
      tags: ['โปรตีนสูง', 'คลีน'],
      protein: 32.0,
      carbs: 34.0,
      fat: 8.0,
    ),
    RecipeModel(
      id: 'rec_4',
      emoji: '🥗',
      name: 'ยำวุ้นเส้นหมูสับ',
      category: 'คลีน',
      cookingMinutes: 15,
      calories: 290,
      estimatedPrice: 48.0,
      description: 'วุ้นเส้น · หมูสับไร้มัน · มะเขือเทศ · หอมใหญ่',
      tags: ['คลีน', 'แคลอรี่ต่ำ'],
      protein: 18.0,
      carbs: 36.0,
      fat: 7.0,
    ),
    RecipeModel(
      id: 'rec_5',
      emoji: '🍳',
      name: 'ไข่กระทะ + ขนมปังโฮลวีต',
      category: 'อาหารไทย',
      cookingMinutes: 15,
      calories: 320,
      estimatedPrice: 35.0,
      description: 'ไข่ไก่ 2 ฟอง · ขนมปังโฮลวีต · หมูสับ · มะเขือเทศ',
      tags: ['มื้อเช้า', 'โปรตีนสูง'],
      protein: 20.0,
      carbs: 30.0,
      fat: 12.0,
    ),
    RecipeModel(
      id: 'rec_6',
      emoji: '🍗',
      name: 'ข้าวไก่ย่าง + ส้มตำ',
      category: 'อาหารไทย',
      cookingMinutes: 30,
      calories: 560,
      estimatedPrice: 65.0,
      description: 'อกไก่หมักสมุนไพร · มะละกอสด · ข้าวเหนียวกล้อง',
      tags: ['อาหารไทย', 'โปรตีนสูง'],
      protein: 35.0,
      carbs: 68.0,
      fat: 14.0,
    ),
    RecipeModel(
      id: 'rec_7',
      emoji: '🍱',
      name: 'ข้าวเต้าหู้เทอริยากิ',
      category: 'มังสวิรัติ',
      cookingMinutes: 22,
      calories: 430,
      estimatedPrice: 58.0,
      description: 'เต้าหู้ขาวแข็ง · ซอสเทอริยากิหวานเค็ม · บรอกโคลี',
      tags: ['มังสวิรัติ', 'ญี่ปุ่น'],
      protein: 22.0,
      carbs: 58.0,
      fat: 11.0,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecipeModel> get _filteredRecipes {
    final query = _searchController.text.trim().toLowerCase();
    return _catalog.where((recipe) {
      final matchesCat =
          _selectedCategory == 'ทั้งหมด' ||
          recipe.category == _selectedCategory ||
          recipe.tags.contains(_selectedCategory);
      final matchesQuery =
          query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.read<MealProvider>();
    final recipes = _filteredRecipes;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('ค้นหาเมนู')),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อเมนูหรือวัตถุดิบ...',
                    hintStyle: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.muted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Recipe Results List
          Expanded(
            child: recipes.isEmpty
                ? const Center(
                    child: Text(
                      'ไม่พบเมนูที่ตรงกับคำค้นหา',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (ctx, index) {
                      final item = recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6EDDF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.category} · ${item.cookingMinutes} นาที · ${item.calories} kcal',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ประมาณ ฿${item.estimatedPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  AddToPlanDialog.show(
                                    context,
                                    recipeName: item.name,
                                    emoji: item.emoji,
                                    price: item.estimatedPrice,
                                    calories: item.calories,
                                    protein: item.protein,
                                    carbs: item.carbs,
                                    fat: item.fat,
                                    mealProvider: mealProvider,
                                  );
                                },
                                child: const Text(
                                  '+ เพิ่ม',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
