const express = require('express');
const router = express.Router();

const mealDbBase = `https://www.themealdb.com/api/json/v1/${process.env.THEMEALDB_API_KEY || '1'}`;

async function fetchMealDb(path) {
  const response = await fetch(`${mealDbBase}/${path}`, { signal: AbortSignal.timeout(12000) });
  if (!response.ok) throw new Error(`TheMealDB returned HTTP ${response.status}`);
  return response.json();
}

function mapMealDbMeal(meal, fallbackCategory = '') {
  const ingredients = [];
  for (let i = 1; i <= 20; i++) {
    const name = meal[`strIngredient${i}`]?.trim();
    const measure = meal[`strMeasure${i}`]?.trim();
    if (name) ingredients.push({ name, measure: measure || '' });
  }
  return {
    id: meal.idMeal,
    emoji: '🍽️',
    name: meal.strMeal || '',
    category: meal.strCategory || fallbackCategory,
    area: meal.strArea || '',
    cookingMinutes: 0,
    calories: 0,
    estimatedPrice: 0,
    description: meal.strInstructions || '',
    instructions: meal.strInstructions || '',
    imageUrl: meal.strMealThumb || '',
    sourceUrl: meal.strSource || '',
    tags: meal.strTags ? meal.strTags.split(',').map((tag) => tag.trim()).filter(Boolean) : [],
    ingredients,
    protein: 0,
    carbs: 0,
    fat: 0,
    nutritionIsEstimated: false,
  };
}

router.get('/categories', async (req, res) => {
  try {
    const result = await fetchMealDb('list.php?c=list');
    const data = (result.meals || []).map((item) => item.strCategory);
    return res.json({ success: true, source: 'themealdb', data });
  } catch (error) {
    return res.status(502).json({ success: false, message: 'Could not load TheMealDB categories', error: error.message });
  }
});

router.get('/', async (req, res) => {
  const { category, q } = req.query;
  try {
    const path = q?.trim()
      ? `search.php?s=${encodeURIComponent(q.trim())}`
      : `filter.php?c=${encodeURIComponent(category || 'Chicken')}`;
    const result = await fetchMealDb(path);
    const data = (result.meals || []).map((meal) => mapMealDbMeal(meal, category || ''));
    return res.json({ success: true, source: 'themealdb', count: data.length, data });
  } catch (error) {
    return res.status(502).json({ success: false, message: 'Could not load recipes from TheMealDB', error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await fetchMealDb(`lookup.php?i=${encodeURIComponent(req.params.id)}`);
    const meal = result.meals?.[0];
    if (!meal) return res.status(404).json({ success: false, message: 'Recipe not found' });
    const data = mapMealDbMeal(meal);
    const openAiKey = process.env.OPENAI_API_KEY;
    if (openAiKey && data.ingredients.length > 0) {
      try {
        const schema = {
          type: 'object',
          properties: {
            calories: { type: 'integer' },
            protein: { type: 'number' },
            carbs: { type: 'number' },
            fat: { type: 'number' },
          },
          required: ['calories', 'protein', 'carbs', 'fat'],
          additionalProperties: false,
        };
        const prompt = `Estimate nutrition for one serving of this recipe. Use ingredient quantities and instructions; if quantities are vague, give a conservative typical serving estimate. Return kcal and grams for protein, carbs, and fat. These are estimates, not measured facts. Recipe: ${data.name}. Ingredients: ${data.ingredients.map((item) => `${item.measure} ${item.name}`).join('; ')}. Instructions: ${data.instructions.slice(0, 3000)}`;
        const response = await fetch('https://api.openai.com/v1/responses', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${openAiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: process.env.OPENAI_MODEL || 'gpt-5-mini',
            reasoning: { effort: 'minimal' },
            max_output_tokens: 250,
            input: [{ role: 'user', content: [{ type: 'input_text', text: prompt }] }],
            text: { format: { type: 'json_schema', name: 'recipe_nutrition_estimate', strict: true, schema } },
          }),
          signal: AbortSignal.timeout(45000),
        });
        if (response.ok) {
          const result = await response.json();
          const outputText = result.output_text || result.output
            ?.flatMap((item) => item.content || [])
            .find((item) => item.type === 'output_text')?.text;
          if (outputText) {
            const nutrition = JSON.parse(outputText);
            if (Number.isFinite(nutrition.calories) && nutrition.calories > 0) {
              data.calories = nutrition.calories;
              data.protein = nutrition.protein;
              data.carbs = nutrition.carbs;
              data.fat = nutrition.fat;
              data.nutritionIsEstimated = true;
            }
          }
        } else {
          const errorBody = await response.text();
          console.warn('Could not estimate recipe nutrition:', response.status, errorBody);
        }
      } catch (error) {
        console.warn('Could not estimate recipe nutrition:', error.message);
      }
    }
    return res.json({ success: true, source: 'themealdb', data });
  } catch (error) {
    return res.status(502).json({ success: false, message: 'Could not load recipe details from TheMealDB', error: error.message });
  }
});

module.exports = router;
