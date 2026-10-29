const express = require('express');
const router = express.Router();

// Fallback food dataset when calling offline or without Gemini Key
const foodPool = [
  {
    name: 'ไข่ต้มกับข้าวสวย',
    mealType: 'มื้อเช้า',
    price: 15.0,
    calories: 250,
    protein: 9.0,
    carbs: 40.0,
    fat: 6.0,
    reason: 'เมนูประหยัดสำหรับงบจำกัด ราคาประมาณการขึ้นอยู่กับพื้นที่',
    ingredients: ['ไข่ไก่', 'ข้าวสวย']
  },
  {
    name: 'ข้าวไข่เจียว',
    mealType: 'มื้อกลางวัน',
    price: 20.0,
    calories: 330,
    protein: 11.0,
    carbs: 42.0,
    fat: 12.0,
    reason: 'เมนูง่าย ๆ ที่เหมาะกับงบจำกัด ราคาประมาณการขึ้นอยู่กับพื้นที่',
    ingredients: ['ไข่ไก่', 'ข้าวสวย']
  },
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
    goal = 'สมดุล',
    cuisines = []
  } = req.body;

  const openAiKey = process.env.OPENAI_API_KEY;
  if (openAiKey) {
    try {
      const mealSchema = {
        type: 'object',
        properties: {
          meals: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                name: { type: 'string' },
                mealType: {
                  type: 'string',
                  enum: ['มื้อเช้า', 'มื้อกลางวัน', 'มื้อเย็น'],
                },
                estimatedPrice: { type: 'number' },
                calories: { type: 'integer' },
                protein: { type: 'number' },
                carbs: { type: 'number' },
                fat: { type: 'number' },
                reason: { type: 'string' },
                ingredients: { type: 'array', items: { type: 'string' } },
              },
              required: [
                'name', 'mealType', 'estimatedPrice', 'calories',
                'protein', 'carbs', 'fat', 'reason', 'ingredients',
              ],
              additionalProperties: false,
            },
          },
        },
        required: ['meals'],
        additionalProperties: false,
      };

      const prompt = `Create ${mealCount} meal recommendations for one day in Thai.
Daily budget: ${budget} THB total. Daily calorie target: ${targetCalories} kcal.
Diet goal: ${goal}. Preferred cuisines: ${Array.isArray(cuisines) ? cuisines.join(', ') : ''}.
Never include these ingredients: ${Array.isArray(dislikedIngredients) ? dislikedIngredients.join(', ') : ''}.
The sum of estimatedPrice must be no more than ${budget} THB. If the budget cannot cover ${mealCount} meals, return fewer meals; do not exceed the budget.
Return realistic Thai meal prices and nutrition estimates. Put a concise Thai explanation in reason.`;
      const response = await fetch('https://api.openai.com/v1/responses', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${openAiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: process.env.OPENAI_MODEL || 'gpt-6-luna',
          reasoning: { effort: 'none' },
          max_output_tokens: 1600,
          input: [
            {
              role: 'developer',
              content: [{
                type: 'input_text',
                text: 'You are a meal-planning assistant. Return only valid data matching the requested schema.',
              }],
            },
            { role: 'user', content: [{ type: 'input_text', text: prompt }] },
          ],
          text: {
            format: {
              type: 'json_schema',
              name: 'promkin_meal_recommendations',
              strict: true,
              schema: mealSchema,
            },
          },
        }),
        // Prevent the app from remaining in its loading state indefinitely if
        // the upstream AI service or the PC's internet connection is stalled.
        signal: AbortSignal.timeout(15000),
      });

      if (response.ok) {
        const result = await response.json();
        const outputText = result.output_text || result.output
          ?.flatMap((item) => item.content || [])
          .find((item) => item.type === 'output_text')?.text;
        if (outputText) {
          const parsed = JSON.parse(outputText);
          if (Array.isArray(parsed.meals)) {
            let remainingBudget = Math.max(0, Number(budget) || 0);
            const excluded = Array.isArray(dislikedIngredients)
              ? dislikedIngredients.map((item) => String(item).toLocaleLowerCase())
              : [];
            const budgetSafeMeals = parsed.meals
              .filter((meal) => meal && Number.isFinite(Number(meal.estimatedPrice)) && Number(meal.estimatedPrice) >= 0)
              .filter((meal) => !Array.isArray(meal.ingredients) || !meal.ingredients.some((ingredient) =>
                excluded.some((disliked) => String(ingredient).toLocaleLowerCase().includes(disliked))
              ))
              .slice(0, Math.max(0, Math.min(6, Number(mealCount) || 0)))
              .filter((meal) => {
                const price = Number(meal.estimatedPrice);
                if (price > remainingBudget) return false;
                remainingBudget -= price;
                return true;
              });
            if (budgetSafeMeals.length > 0) {
              return res.json({
                success: true,
                source: `openai-${process.env.OPENAI_MODEL || 'gpt-6-luna'}`,
                data: budgetSafeMeals,
              });
            }
          }
        }
      } else {
        const errorBody = await response.text();
        console.warn('OpenAI request failed, using fallback recommendations:', response.status, errorBody);
      }
    } catch (err) {
      console.warn('OpenAI request failed, using fallback recommendations:', err.message);
    }
  }

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
- ประเภทอาหารที่ชอบ: ${Array.isArray(cuisines) ? cuisines.join(', ') : ''}
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
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${geminiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { responseMimeType: 'application/json' }
          }),
          signal: AbortSignal.timeout(12000),
        }
      );

      if (response.ok) {
        const result = await response.json();
        const text = result?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          const parsed = JSON.parse(text);
          if (Array.isArray(parsed)) {
            return res.json({ success: true, source: 'gemini-3.6-flash', data: parsed });
          }
        }
      }
    } catch (err) {
      console.warn('Gemini API call failed, falling back to smart rules:', err.message);
    }
  }

  // Smart Rule-based AI Engine (Filtered by constraints & allergies)
  const excluded = Array.isArray(dislikedIngredients)
    ? dislikedIngredients.map((item) => String(item).toLocaleLowerCase())
    : [];
  const safeItems = foodPool.filter((item) => !item.ingredients.some((ingredient) =>
    excluded.some((disliked) => ingredient.toLocaleLowerCase().includes(disliked))
  ));

  // Keep rule-based recommendations within the user's daily budget.
  let remainingBudget = Math.max(0, Number(budget) || 0);
  const recommendations = [];
  for (const item of safeItems) {
    if (recommendations.length >= Math.max(0, Math.min(6, Number(mealCount) || 0))) break;
    if (item.price > remainingBudget) continue;
    remainingBudget -= item.price;
    recommendations.push({
      name: item.name,
      mealType: item.mealType,
      estimatedPrice: item.price,
      calories: item.calories,
      protein: item.protein,
      carbs: item.carbs,
      fat: item.fat,
      reason: item.reason,
      ingredients: item.ingredients
    });
  }

  res.json({
    success: true,
    source: 'rule-based-ai',
    message: 'Personalized meal recommendations generated successfully',
    data: recommendations
  });
});

module.exports = router;
