// services/gemini_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/recipe_card.dart';

class GeminiService {
  static const String _apiKey = ''; // Replace with actual API key
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  static Future<List<RecipeCard>> generateRecipes({
    required File image,
    required String imageType, // 'grocery_bill' or 'refrigerator'
    required UserProfile userProfile,
  }) async {
    try {
      // Convert image to base64
      final Uint8List imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Create the prompt based on image type and user profile
      final String prompt = _buildPrompt(imageType, userProfile);

      // Send request to Gemini API
      final response = await _sendGeminiRequest(prompt, base64Image);

      // Parse response and return recipe cards
      return _parseRecipeResponse(response);
    } catch (e) {
      throw Exception('Failed to generate recipes: $e');
    }
  }

  static String _buildPrompt(String imageType, UserProfile userProfile) {
    final StringBuffer prompt = StringBuffer();
    
    // Base prompt based on image type
    if (imageType == 'grocery_bill') {
      prompt.write('''
Analyze this grocery bill/receipt image and extract all food items purchased. Based on these ingredients, create 6-8 healthy and delicious recipe suggestions with DETAILED measurements and cooking instructions.
''');
    } else {
      prompt.write('''
Analyze this refrigerator/pantry image and identify all visible food items and ingredients. Based on what's available, create 6-8 recipe suggestions using these ingredients with PRECISE measurements and step-by-step cooking instructions.
''');
    }

    // Add user nutrition requirements
    prompt.write('''

USER NUTRITION REQUIREMENTS:
- Daily Protein Goal: ${userProfile.proteinGoal}g
- Height: ${userProfile.height}${userProfile.isMetric ? 'cm' : 'ft'}
- Weight: ${userProfile.weight}${userProfile.isMetric ? 'kg' : 'lbs'}
- Unit System: ${userProfile.isMetric ? 'Metric' : 'Imperial'}
''');

    // Add dietary preferences
    if (userProfile.cuisines.isNotEmpty) {
      prompt.write('\n- Preferred Cuisines: ${userProfile.cuisines.join(', ')}');
    }

    if (userProfile.restrictions.isNotEmpty) {
      prompt.write('\n- Dietary Restrictions: ${userProfile.restrictions.join(', ')}');
    }

    // Add specific formatting requirements with detailed instructions
    prompt.write('''

RECIPE REQUIREMENTS:
1. Include EXACT measurements for all ingredients (number of items, cups, tablespoons, grams, etc.)
2. Provide DETAILED step-by-step cooking instructions with specific times and temperatures
3. Include prep time, cooking time, and total time
4. Specify serving sizes
5. Add cooking tips and techniques where helpful
6. Include storage and reheating instructions if applicable

RESPONSE FORMAT REQUIREMENTS:
Return ONLY a valid JSON array with exactly this structure for each recipe:

[
  {
    "id": "unique_recipe_id",
    "name": "Recipe Name",
    "description": "Brief appetizing description (2-3 sentences)",
    "mealType": "breakfast|lunch|dinner|snack",
    "servings": 2,
    "ingredients": [
      "2 large eggs",
      "1/4 cup (60ml) whole milk",
      "2 tablespoons (30g) unsalted butter",
      "1/2 cup (50g) sharp cheddar cheese, grated",
      "2 tablespoons fresh chives, chopped",
      "1/2 teaspoon salt",
      "1/4 teaspoon black pepper"
    ],
    "instructions": [
      "Crack 2 large eggs into a medium bowl and whisk vigorously for 30 seconds until well combined.",
      "Add 1/4 cup milk, 1/2 teaspoon salt, and 1/4 teaspoon pepper to the eggs. Whisk for another 15 seconds.",
      "Heat 2 tablespoons butter in a non-stick pan over medium-low heat (about 300°F) for 1-2 minutes until melted and foaming.",
      "Pour the egg mixture into the pan and let it sit undisturbed for 20-30 seconds.",
      "Using a rubber spatula, gently push the cooked edges toward the center every 15-20 seconds, tilting the pan to let uncooked egg flow underneath.",
      "Continue this process for 2-3 minutes until eggs are almost set but still slightly wet on top.",
      "Remove from heat and immediately sprinkle 1/2 cup grated cheese over the eggs.",
      "Gently fold the eggs once or twice, then let sit for 30 seconds to finish cooking with residual heat.",
      "Garnish with 2 tablespoons fresh chives and serve immediately on warmed plates."
    ],
    "prepTime": 5,
    "cookTime": 8,
    "totalTime": 13,
    "protein": 28.5,
    "calories": 420,
    "carbs": 3.2,
    "fats": 32.8,
    "difficulty": "Easy",
    "tags": ["High-Protein", "Quick", "Breakfast"],
    "cookingTips": [
      "Keep heat at medium-low to prevent overcooking",
      "Fresh herbs can be substituted with 1 teaspoon dried herbs",
      "For fluffier eggs, add 1 tablespoon of cream cheese"
    ],
    "storage": "Best served immediately. Leftovers can be refrigerated for 1 day and reheated gently in microwave for 20-30 seconds."
  }
]

IMPORTANT GUIDELINES:
1. Use specific measurements with units (cups, tablespoons, grams, ounces, etc.)
2. Include precise cooking times and temperatures
3. Specify pan sizes, heat levels, and cooking techniques
4. Add timing for each step (e.g., "cook for 5-7 minutes", "whisk for 30 seconds")
5. Include visual cues (e.g., "until golden brown", "until bubbling")
6. Provide serving suggestions and garnish ideas
7. Add helpful cooking tips for better results
8. Ensure recipes are practical and achievable
9. Include storage and leftover handling instructions
10. Make instructions foolproof for beginners while being detailed enough for experienced cooks

Return ONLY the JSON array, no additional text or explanations.
''');

    return prompt.toString();
  }

  static Future<Map<String, dynamic>> _sendGeminiRequest(
    String prompt,
    String base64Image,
  ) async {
    final url = Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey');
    
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": prompt,
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 8192,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  static List<RecipeCard> _parseRecipeResponse(Map<String, dynamic> response) {
    try {
      // Extract text from Gemini response
      final candidates = response['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response candidates found');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No response parts found');
      }

      final responseText = parts[0]['text'] as String?;
      if (responseText == null) {
        throw Exception('No response text found');
      }

      // Clean and parse JSON
      String cleanedJson = responseText.trim();
      
      // Remove any markdown formatting
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.replaceFirst('```json', '');
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.lastIndexOf('```'));
      }
      
      cleanedJson = cleanedJson.trim();

      // Parse JSON array
      final List<dynamic> recipesJson = jsonDecode(cleanedJson);
      
      // Convert to RecipeCard objects
      final List<RecipeCard> recipes = [];
      for (int i = 0; i < recipesJson.length; i++) {
        try {
          final recipeData = recipesJson[i] as Map<String, dynamic>;
          
          // Ensure required fields exist with defaults
          recipeData['id'] = recipeData['id'] ?? 'recipe_$i';
          recipeData['name'] = recipeData['name'] ?? 'Untitled Recipe';
          recipeData['description'] = recipeData['description'] ?? 'Delicious recipe';
          recipeData['mealType'] = recipeData['mealType'] ?? 'snack';
          recipeData['ingredients'] = recipeData['ingredients'] ?? [];
          recipeData['instructions'] = recipeData['instructions'] ?? [];
          recipeData['protein'] = (recipeData['protein'] ?? 10).toDouble();
          recipeData['calories'] = (recipeData['calories'] ?? 200).toDouble();
          recipeData['carbs'] = (recipeData['carbs'] ?? 20).toDouble();
          recipeData['fats'] = (recipeData['fats'] ?? 8).toDouble();
          recipeData['prepTime'] = recipeData['prepTime'] ?? 30;
          recipeData['difficulty'] = recipeData['difficulty'] ?? 'Medium';
          recipeData['tags'] = recipeData['tags'] ?? [];

          final recipe = RecipeCard.fromJson(recipeData);
          recipes.add(recipe);
        } catch (e) {
          print('Error parsing recipe $i: $e');
          // Continue with other recipes
        }
      }

      if (recipes.isEmpty) {
        throw Exception('No valid recipes could be parsed');
      }

      return recipes;
    } catch (e) {
      // Fallback: return mock recipes if parsing fails
      print('Error parsing Gemini response: $e');
      return _generateMockRecipes();
    }
  }

  // Fallback method for testing when Gemini API is not available
  static List<RecipeCard> _generateMockRecipes() {
    return [
      RecipeCard(
        id: 'mock_1',
        name: 'Protein-Packed Scrambled Eggs',
        description: 'Fluffy scrambled eggs with cheese and herbs, perfect for a high-protein breakfast.',
        mealType: 'breakfast',
        ingredients: ['Eggs', 'Cheese', 'Butter', 'Herbs', 'Salt', 'Pepper'],
        instructions: [
          'Crack eggs into a bowl and whisk',
          'Heat butter in pan over medium heat',
          'Add eggs and gently scramble',
          'Add cheese and herbs just before serving'
        ],
        protein: 28.0,
        calories: 320,
        carbs: 2.0,
        fats: 24.0,
        prepTime: 10,
        difficulty: 'Easy',
        tags: ['High-Protein', 'Quick', 'Breakfast'],
      ),
      RecipeCard(
        id: 'mock_2',
        name: 'Grilled Chicken Salad',
        description: 'Fresh garden salad topped with seasoned grilled chicken breast and vinaigrette.',
        mealType: 'lunch',
        ingredients: ['Chicken breast', 'Mixed greens', 'Tomatoes', 'Cucumber', 'Olive oil', 'Lemon'],
        instructions: [
          'Season and grill chicken breast',
          'Prepare fresh salad vegetables',
          'Make simple vinaigrette',
          'Slice chicken and serve over salad'
        ],
        protein: 35.0,
        calories: 380,
        carbs: 12.0,
        fats: 18.0,
        prepTime: 25,
        difficulty: 'Medium',
        tags: ['Healthy', 'Low-Carb', 'Lunch'],
      ),
      RecipeCard(
        id: 'mock_3',
        name: 'Salmon with Roasted Vegetables',
        description: 'Baked salmon fillet with a colorful medley of roasted seasonal vegetables.',
        mealType: 'dinner',
        ingredients: ['Salmon fillet', 'Broccoli', 'Bell peppers', 'Zucchini', 'Olive oil', 'Garlic'],
        instructions: [
          'Preheat oven to 400°F',
          'Season salmon with herbs and lemon',
          'Toss vegetables with olive oil and garlic',
          'Bake everything together for 20 minutes'
        ],
        protein: 42.0,
        calories: 450,
        carbs: 15.0,
        fats: 22.0,
        prepTime: 30,
        difficulty: 'Medium',
        tags: ['Omega-3', 'Healthy', 'Dinner'],
      ),
      RecipeCard(
        id: 'mock_4',
        name: 'Greek Yogurt Berry Bowl',
        description: 'Creamy Greek yogurt topped with fresh berries, nuts, and a drizzle of honey.',
        mealType: 'snack',
        ingredients: ['Greek yogurt', 'Mixed berries', 'Almonds', 'Honey', 'Granola'],
        instructions: [
          'Add Greek yogurt to a bowl',
          'Top with fresh berries',
          'Sprinkle with nuts and granola',
          'Drizzle with honey'
        ],
        protein: 20.0,
        calories: 280,
        carbs: 35.0,
        fats: 8.0,
        prepTime: 5,
        difficulty: 'Easy',
        tags: ['High-Protein', 'Healthy', 'Snack'],
      ),
    ];
  }

  // Method to test API connection
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/models?key=$_apiKey');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}