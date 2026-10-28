const express = require('express');
const router = express.Router();

// In-memory data store for initial team development (can easily be swapped with SQLite or Firestore)
let meals = [
  {
    id: 'meal_1',
    name: 'ไข่กระทะ + ขนมปังโฮลวีต',
    mealType: 'มื้อเช้า',
    price: 35.0,
    calories: 320,
    protein: 20.0,
    carbs: 30.0,
    fat: 12.0,
    date: '2026-10-28',
    isCompleted: false,
    emoji: '🍳',
    time: '07:30',
    tags: ['โปรตีนสูง', 'ทำง่าย']
  },
  {
    id: 'meal_2',
    name: 'ก๋วยเตี๋ยวต้มยำหมู',
    mealType: 'มื้อกลางวัน',
    price: 55.0,
    calories: 480,
    protein: 24.0,
    carbs: 62.0,
    fat: 14.0,
    date: '2026-10-28',
    isCompleted: false,
    emoji: '🍜',
    time: '12:00',
    tags: ['อาหารไทย', 'รสแซ่บ']
  },
  {
    id: 'meal_3',
    name: 'ข้าวกะเพราเต้าหู้ไข่',
    mealType: 'มื้อเย็น',
    price: 45.0,
    calories: 380,
    protein: 18.0,
    carbs: 52.0,
    fat: 10.0,
    date: '2026-10-28',
    isCompleted: false,
    emoji: '🍛',
    time: '18:30',
    tags: ['มังสวิรัติ', 'AI แนะนำ']
  }
];

// GET /api/meals - Retrieve meals (optionally filter by date)
router.get('/', (req, res) => {
  const { date } = req.query;
  if (date) {
    const filtered = meals.filter((m) => m.date === date);
    return res.json({ success: true, count: filtered.length, data: filtered });
  }
  res.json({ success: true, count: meals.length, data: meals });
});

// POST /api/meals - Add a new meal to planner
router.post('/', (req, res) => {
  const { name, mealType, price, calories, protein, carbs, fat, date, emoji, time, tags } = req.body;
  if (!name || !mealType) {
    return res.status(400).json({ success: false, message: 'Meal name and mealType are required.' });
  }

  const newMeal = {
    id: `meal_${Date.now()}`,
    name,
    mealType,
    price: Number(price) || 0.0,
    calories: Number(calories) || 0,
    protein: Number(protein) || 0.0,
    carbs: Number(carbs) || 0.0,
    fat: Number(fat) || 0.0,
    date: date || new Date().toISOString().split('T')[0],
    isCompleted: false,
    emoji: emoji || '🍛',
    time: time || '12:00',
    tags: Array.isArray(tags) ? tags : []
  };

  meals.push(newMeal);
  res.status(201).json({ success: true, message: 'Meal created successfully', data: newMeal });
});

// PUT /api/meals/:id - Update or toggle meal status
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const index = meals.findIndex((m) => m.id === id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Meal not found' });
  }

  meals[index] = { ...meals[index], ...req.body };
  res.json({ success: true, message: 'Meal updated', data: meals[index] });
});

// DELETE /api/meals/:id - Remove meal
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  const beforeCount = meals.length;
  meals = meals.filter((m) => m.id !== id);

  if (meals.length === beforeCount) {
    return res.status(404).json({ success: false, message: 'Meal not found' });
  }
  res.json({ success: true, message: 'Meal deleted successfully' });
});

module.exports = router;
