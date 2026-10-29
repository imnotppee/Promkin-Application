import 'dart:async';

import 'package:flutter/material.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/widgets/promkin_header.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_model.dart';
import 'package:promkin_app/features/recipe_search/data/recipe_service.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/meal_provider.dart';
import 'package:promkin_app/features/meal_planner/presentation/widgets/add_to_plan_dialog.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();
  final List<String> _categories = [];
  List<RecipeModel> _recipes = [];
  String _selectedCategory = 'Chicken';
  String? _error;
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _recipeService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories
          ..clear()
          ..addAll(categories);
        if (!_categories.contains(_selectedCategory) &&
            _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } catch (_) {
      // Still load the default category; the recipe request displays any error.
    }
    await _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final recipes = await _recipeService.search(
        query: _searchController.text,
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() => _recipes = recipes);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadRecipes);
  }

  Future<void> _showDetails(RecipeModel recipe) async {
    final detailsFuture = _recipeService.getDetails(recipe.id);
    final parentContext = context;
    final mealProvider = context.read<MealProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => FutureBuilder<RecipeModel>(
        future: detailsFuture,
        builder: (context, snapshot) {
          final details = snapshot.data ?? recipe;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.82,
                child: snapshot.connectionState != ConnectionState.done
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                    ? const Center(child: Text('โหลดรายละเอียดเมนูไม่สำเร็จ'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    details.imageUrl,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(
                                          height: 100,
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 48,
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  details.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    details.category,
                                    details.area,
                                  ].where((v) => v.isNotEmpty).join(' · '),
                                ),
                                const SizedBox(height: 16),
                                _nutritionCard(details),
                                const SizedBox(height: 18),
                                Text(
                                  'วัตถุดิบ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                ...details.ingredients.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      '• ${item['name']} ${item['measure']}'
                                          .trim(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'วิธีทำ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(details.instructions),
                                if (details.sourceUrl.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  SelectableText('ที่มา: ${details.sourceUrl}'),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                AddToPlanDialog.show(
                                  parentContext,
                                  recipeName: details.name,
                                  emoji: details.emoji,
                                  imageUrl: details.imageUrl,
                                  price: details.estimatedPrice > 0
                                      ? details.estimatedPrice
                                      : 50,
                                  calories: details.calories > 0
                                      ? details.calories
                                      : null,
                                  protein: details.protein > 0
                                      ? details.protein
                                      : null,
                                  carbs: details.carbs > 0
                                      ? details.carbs
                                      : null,
                                  fat: details.fat > 0 ? details.fat : null,
                                  mealProvider: mealProvider,
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              label: const Text('เพิ่มเมนูไปที่แผนมื้ออาหาร'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addRecipeToPlan(RecipeModel recipe) async {
    var details = recipe;
    try {
      details = await _recipeService.getDetails(recipe.id);
    } catch (_) {
      // The recipe list still contains enough information to schedule it.
    }
    if (!mounted) return;
    await AddToPlanDialog.show(
      context,
      recipeName: details.name,
      emoji: details.emoji,
      imageUrl: details.imageUrl,
      price: details.estimatedPrice > 0 ? details.estimatedPrice : 50,
      calories: details.calories > 0 ? details.calories : null,
      protein: details.protein > 0 ? details.protein : null,
      carbs: details.carbs > 0 ? details.carbs : null,
      fat: details.fat > 0 ? details.fat : null,
      mealProvider: context.read<MealProvider>(),
    );
  }

  Widget _nutritionCard(RecipeModel recipe) {
    final hasNutrition =
        recipe.calories > 0 ||
        recipe.protein > 0 ||
        recipe.carbs > 0 ||
        recipe.fat > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'แคลอรีและโภชนาการ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _nutritionValue(
                'พลังงาน',
                recipe.calories > 0 ? '${recipe.calories} kcal' : '—',
              ),
              _nutritionValue(
                'โปรตีน',
                recipe.protein > 0
                    ? '${recipe.protein.toStringAsFixed(0)} g'
                    : '—',
              ),
              _nutritionValue(
                'คาร์บ',
                recipe.carbs > 0 ? '${recipe.carbs.toStringAsFixed(0)} g' : '—',
              ),
              _nutritionValue(
                'ไขมัน',
                recipe.fat > 0 ? '${recipe.fat.toStringAsFixed(0)} g' : '—',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasNutrition && recipe.nutritionIsEstimated
                ? 'โภชนาการเป็นค่าประมาณจาก AI ต่อหนึ่งที่ อาจคลาดเคลื่อน'
                : hasNutrition
                ? 'ข้อมูลโภชนาการจากรายละเอียดเมนู'
                : 'TheMealDB ไม่ได้ให้ข้อมูลโภชนาการของเมนูนี้ จึงแสดงเป็น —',
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _nutritionValue(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: FadeSlideIn(
          child: Column(
            children: [
              PromkinHeader(
                onTune: () => FocusScope.of(context).requestFocus(FocusNode()),
                onProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ค้นหาเมนู',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'เลือกเมนูที่เข้ากับงบและความชอบ',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_recipes.length} เมนูแนะนำ',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาเมนูหรือวัตถุดิบ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadRecipes();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              if (_categories.isNotEmpty)
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_categoryLabel(category)),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() => _selectedCategory = category);
                            _loadRecipes();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadRecipes,
                              child: const Text('ลองอีกครั้ง'),
                            ),
                          ],
                        ),
                      )
                    : _recipes.isEmpty
                    ? const Center(
                        child: Text('ไม่พบเมนู ลองค้นหาด้วยชื่อภาษาอังกฤษ'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.ink.withAlpha(8),
                                  blurRadius: 13,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _showDetails(recipe),
                              borderRadius: BorderRadius.circular(15),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      recipe.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: AppColors.primaryContainer,
                                        alignment: Alignment.center,
                                        child: Text(
                                          recipe.emoji,
                                          style: const TextStyle(fontSize: 34),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: _tag(
                                            _categoryLabel(recipe.category),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          recipe.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          [recipe.area, recipe.category]
                                              .where((v) => v.isNotEmpty)
                                              .join(' · '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color: AppColors.muted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              recipe.cookingMinutes > 0
                                                  ? '${recipe.cookingMinutes} นาที'
                                                  : 'ดูวิธีทำ',
                                              style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton.filledTonal(
                                              tooltip:
                                                  'เพิ่มเมนูไปที่แผนมื้ออาหาร',
                                              onPressed: () =>
                                                  _addRecipeToPlan(recipe),
                                              icon: const Icon(
                                                Icons.add_rounded,
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              style: IconButton.styleFrom(
                                                backgroundColor: AppColors
                                                    .secondaryContainer,
                                                foregroundColor:
                                                    AppColors.primary,
                                                fixedSize: const Size(36, 36),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Recipes and images provided by TheMealDB',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(String category) => switch (category.toLowerCase()) {
    'chicken' => 'ไก่',
    'beef' => 'เนื้อวัว',
    'seafood' => 'อาหารทะเล',
    'vegetarian' => 'มังสวิรัติ',
    'dessert' => 'ของหวาน',
    'pasta' => 'พาสต้า',
    'side' => 'เครื่องเคียง',
    'starter' => 'เรียกน้ำย่อย',
    'vegan' => 'วีแกน',
    'breakfast' => 'อาหารเช้า',
    'miscellaneous' => 'อื่น ๆ',
    _ => category,
  };

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE3EEE2),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
