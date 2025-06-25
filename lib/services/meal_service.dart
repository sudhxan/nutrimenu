// services/meal_service.dart
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import 'gemini_service.dart';

class MealService {
  /// Generate meal plan using Gemini AI
  static Future<List<MealPlan>> generateMealPlan({
    required UserProfile profile,
    required List<String> groceryItems,
    int days = 5,
  }) async {
    try {
      // Use Gemini AI to generate meal suggestions
      final geminiResponse = await GeminiService.generateMealSuggestions(
        groceryItems: groceryItems,
        proteinGoal: profile.proteinGoal,
        cuisinePreferences: profile.cuisines,
        dietaryRestrictions: profile.restrictions,
        days: days,
      );

      // For now, we'll create a simplified meal plan
      // In a real implementation, you'd parse the JSON response from Gemini
      final plans = <MealPlan>[];
      final now = DateTime.now();

      // Create sample meals based on available ingredients
      final sampleMeals = _createMealsFromIngredients(groceryItems, profile);

      for (int i = 0; i < days; i++) {
        plans.add(MealPlan(
          date: now.add(Duration(days: i)),
          breakfast: sampleMeals[(i * 3) % sampleMeals.length],
          lunch: sampleMeals[(i * 3 + 1) % sampleMeals.length],
          dinner: sampleMeals[(i * 3 + 2) % sampleMeals.length],
        ));
      }

      return plans;
    } catch (e) {
      // If Gemini service fails, rethrow the error
      rethrow;
    }
  }

  /// Create meals based on available ingredients
  static List<Meal> _createMealsFromIngredients(List<String> ingredients, UserProfile profile) {
    final meals = <Meal>[];
    
    // Create meals based on common ingredients
    if (ingredients.any((item) => item.toLowerCase().contains('chicken'))) {
      meals.add(Meal(
        id: 'chicken_1',
        name: 'Grilled Chicken with Vegetables',
        cuisine: profile.cuisines.isNotEmpty ? profile.cuisines.first : 'American',
        protein: 35,
        calories: 420,
        carbs: 15,
        fats: 18,
        ingredients: ingredients.where((item) => 
          item.toLowerCase().contains('chicken') ||
          item.toLowerCase().contains('vegetable') ||
          item.toLowerCase().contains('spinach') ||
          item.toLowerCase().contains('broccoli')
        ).take(4).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 25,
        difficulty: 'Medium',
      ));
    }

    if (ingredients.any((item) => item.toLowerCase().contains('rice'))) {
      meals.add(Meal(
        id: 'rice_1',
        name: 'Protein Rice Bowl',
        cuisine: 'Asian',
        protein: 28,
        calories: 380,
        carbs: 45,
        fats: 12,
        ingredients: ingredients.where((item) => 
          item.toLowerCase().contains('rice') ||
          item.toLowerCase().contains('egg') ||
          item.toLowerCase().contains('vegetable')
        ).take(4).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 20,
        difficulty: 'Easy',
      ));
    }

    if (ingredients.any((item) => item.toLowerCase().contains('pasta') || item.toLowerCase().contains('spaghetti'))) {
      meals.add(Meal(
        id: 'pasta_1',
        name: 'Healthy Pasta',
        cuisine: 'Italian',
        protein: 22,
        calories: 450,
        carbs: 55,
        fats: 16,
        ingredients: ingredients.where((item) => 
          item.toLowerCase().contains('pasta') ||
          item.toLowerCase().contains('spaghetti') ||
          item.toLowerCase().contains('tomato') ||
          item.toLowerCase().contains('cheese')
        ).take(4).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 18,
        difficulty: 'Easy',
      ));
    }

    // Add default meals if we don't have enough
    if (meals.length < 6) {
      meals.addAll(_getDefaultMeals(ingredients));
    }

    return meals.take(10).toList(); // Limit to 10 meals
  }

  /// Get default meals when specific ingredients aren't available
  static List<Meal> _getDefaultMeals(List<String> availableIngredients) {
    return [
      Meal(
        id: 'default_1',
        name: 'Healthy Breakfast Bowl',
        cuisine: 'American',
        protein: 20,
        calories: 320,
        carbs: 30,
        fats: 12,
        ingredients: availableIngredients.take(3).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 10,
        difficulty: 'Easy',
      ),
      Meal(
        id: 'default_2',
        name: 'Quick Lunch Salad',
        cuisine: 'Mediterranean',
        protein: 25,
        calories: 350,
        carbs: 20,
        fats: 15,
        ingredients: availableIngredients.take(4).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 15,
        difficulty: 'Easy',
      ),
      Meal(
        id: 'default_3',
        name: 'Balanced Dinner',
        cuisine: 'International',
        protein: 32,
        calories: 480,
        carbs: 35,
        fats: 20,
        ingredients: availableIngredients.take(5).toList(),
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 30,
        difficulty: 'Medium',
      ),
    ];
  }

  static List<Meal> getMealsByCuisine(String cuisine) {
    // This could also use Gemini AI to generate cuisine-specific meals
    return _getDefaultMeals([]).where((meal) => meal.cuisine == cuisine).toList();
  }
}