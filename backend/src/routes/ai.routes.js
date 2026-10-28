const express = require('express');
const router = express.Router();

// Fallback food dataset when calling offline or without Gemini Key
const foodPool = [
  {
    name: 'ไข่กระทะ + ขนมปังโฮลวีต',
    mealType: 'มื้อเช้า',
    price: 35.0,
    calories: 320,
    protein: 20.0,
    carbs: 30.0,
    fat: 12.0,
    reason: 'โปรตีนสูงจากไข่ไก่ ทำง่าย รวดเร็ว และประหยัดงบ',
    ingredients: ['ไข่ไก่', 'ขนมปังโฮลวีต', 'มะเขือเทศ']
  },
  {
    name: 'ก๋วยเตี๋ยวต้มยำหมู',
    mealType: 'มื้อกลางวัน',
    price: 55.0,
    calories: 480,
    protein: 24.0,
    carbs: 62.0,
    fat: 14.0,
    reason: 'อาหารจานเดียวรสจัดจ้าน ให้พลังงานพอดีสำหรับช่วงบ่าย',
    ingredients: ['หมูสับ', 'เส้นเล็ก', 'ถั่วลิสง']
  },
  {
    name: 'ข้าวกะเพราเต้าหู้ไข่',
    mealType: 'มื้อเย็น',
    price: 45.0,
    calories: 380,
    protein: 18.0,
    carbs: 52.0,
    fat: 10.0,
    reason: 'มังสวิรัติย่อยง่าย ไขมันต่ำ อยู่ในงบประมาณยามเย็น',
    ingredients: ['เต้าหู้ไข่', 'ใบกะเพรา', 'ข้าวกล้อง']
  },
  {
    name: 'สุกี้น้ำไก่',
    mealType: 'มื้อกลางวัน',
    price: 50.0,
    calories: 360,
    protein: 31.0,
    carbs: 34.0,
    fat: 8.0,
    reason: 'โปรตีนสูง ไขมันต่ำ ผักเยอะ เหมาะกับการคุมน้ำหนัก',
    ingredients: ['อกไก่', 'ผักกาดขาว', 'วุ้นเส้น']
  },
  {
    name: 'ยำวุ้นเส้นหมูสับ',
    mealType: 'มื้อเย็น',
    price: 48.0,
    calories: 290,
    protein: 18.0,
    carbs: 36.0,
    fat: 7.0,
    reason: 'แคลอรีต่ำ รสชาติแซ่บ ไม่อ้วนยามเย็น',
    ingredients: ['วุ้นเส้น', 'หมูสับ', 'มะเขือเทศ']
  }
];

// POST /api/ai/recommend - Generate personalized AI meal plan
router.post('/recommend', async (req, res) => {
  const {
    budget = 180,
    targetCalories = 2000,
    mealCount = 3,
    dislikedIngredients = ['ถั่วลิสง'],
    goal = 'สมดุล'
  } = req.body;

  const geminiKey = process.env.GEMINI_API_KEY;

  // If Gemini API Key is configured, teammate can call Google Gemini API directly
  if (geminiKey && geminiKey !== 'your_gemini_api_key_here') {
    try {
      const prompt = `คุณคือผู้เชี่ยวชาญด้านโภชนาการสำหรับแอป PROM KIN
กรุณาแนะนำเมนูอาหารจำนวน ${mealCount} มื้อ สำหรับ 1 วัน
เงื่อนไข:
- งบประมาณรวมต่อวัน: ไม่เกิน ${budget} บาท
- แคลอรีรวม: ประมาณ ${targetCalories} kcal
- วัตถุดิบที่ไม่ต้องการ/แพ้: ${dislikedIngredients.join(', ')}
- เป้าหมาย: ${goal}
ตอบกลับเป็น JSON array ของวัตถุที่มีรูปแบบ:
[
  {
    "name": "ชื่อเมนู",
    "mealType": "มื้อเช้า/มื้อกลางวัน/มื้อเย็น",
    "estimatedPrice": 45,
    "calories": 400,
    "protein": 20,
    "carbs": 50,
    "fat": 10,
    "reason": "เหตุผลที่แนะนำ",
    "ingredients": ["วัตถุดิบ 1", "วัตถุดิบ 2"]
  }
]`;

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { responseMimeType: 'application/json' }
          })
        }
      );

      if (response.ok) {
        const result = await response.json();
        const text = result?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          const parsed = JSON.parse(text);
          return res.json({ success: true, source: 'gemini-1.5-flash', data: parsed });
        }
      }
    } catch (err) {
      console.warn('Gemini API call failed, falling back to smart rules:', err.message);
    }
  }

  // Smart Rule-based AI Engine (Filtered by constraints & allergies)
  const safeItems = foodPool.filter((item) => {
    return !item.ingredients.some((ing) => dislikedIngredients.includes(ing));
  });

  // Pick up to mealCount items
  const recommendations = safeItems.slice(0, mealCount).map((item) => ({
    name: item.name,
    mealType: item.mealType,
    estimatedPrice: item.price,
    calories: item.calories,
    protein: item.protein,
    carbs: item.carbs,
    fat: item.fat,
    reason: item.reason,
    ingredients: item.ingredients
  }));

  res.json({
    success: true,
    source: 'rule-based-ai',
    message: 'Personalized meal recommendations generated successfully',
    data: recommendations
  });
});

module.exports = router;
