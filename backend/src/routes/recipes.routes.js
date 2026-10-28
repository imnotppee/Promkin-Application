const express = require('express');
const router = express.Router();

const recipeCatalog = [
  {
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
    fat: 10.0
  },
  {
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
    fat: 14.0
  },
  {
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
    fat: 8.0
  },
  {
    id: 'rec_4',
    emoji: '🥗',
    name: 'ยำวุ้นเส้นหมูสับ',
    category: 'คลีน',
    cookingMinutes: 15,
    calories: 290,
    estimatedPrice: 48.0,
    description: 'วุ้นเส้น · หมูสับไร้มัน · มะเขือเทศ · หอมใหญ่',
    tags: ['คลีน', 'แคลอรีต่ำ'],
    protein: 18.0,
    carbs: 36.0,
    fat: 7.0
  },
  {
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
    fat: 12.0
  },
  {
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
    fat: 14.0
  },
  {
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
    fat: 11.0
  }
];

// GET /api/recipes - Fetch all recipes
router.get('/', (req, res) => {
  const { category, q } = req.query;
  let results = [...recipeCatalog];

  if (category && category !== 'ทั้งหมด') {
    results = results.filter((r) => r.category === category || r.tags.includes(category));
  }

  if (q) {
    const query = q.toLowerCase();
    results = results.filter(
      (r) => r.name.toLowerCase().includes(query) || r.description.toLowerCase().includes(query)
    );
  }

  res.json({ success: true, count: results.length, data: results });
});

// GET /api/recipes/:id - Get recipe detail
router.get('/:id', (req, res) => {
  const recipe = recipeCatalog.find((r) => r.id === req.params.id);
  if (!recipe) {
    return res.status(404).json({ success: false, message: 'Recipe not found' });
  }
  res.json({ success: true, data: recipe });
});

module.exports = router;

