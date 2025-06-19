// services/meal_service.dart
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';

class MealService {
  // Mock data for demonstration
  static final List<Meal> _mockMeals = [
    Meal(
      id: '1',
      name: 'Grilled Chicken Salad',
      cuisine: 'American',
      protein: 35,
      calories: 420,
      carbs: 15,
      fats: 18,
      ingredients: ['Chicken breast', 'Mixed greens', 'Tomatoes', 'Avocado'],
      imageUrl: 'https://via.placeholder.com/300',
      prepTime: 20,
      difficulty: 'Easy',
    ),
    Meal(
      id: '2',
      name: 'Spaghetti Carbonara',
      cuisine: 'Italian',
      protein: 25,
      calories: 580,
      carbs: 65,
      fats: 22,
      ingredients: ['Spaghetti', 'Eggs', 'Bacon', 'Parmesan'],
      imageUrl: 'https://via.placeholder.com/300',
      prepTime: 25,
      difficulty: 'Medium',
    ),
    Meal(
      id: '3',
      name: 'Chicken Tikka Masala',
      cuisine: 'Indian',
      protein: 32,
      calories: 490,
      carbs: 35,
      fats: 20,
      ingredients: ['Chicken', 'Yogurt', 'Tomatoes', 'Spices', 'Rice'],
      imageUrl: 'https://via.placeholder.com/300',
      prepTime: 40,
      difficulty: 'Medium',
    ),
  ];

  static Future<List<MealPlan>> generateMealPlan({
    required UserProfile profile,
    required List<String> groceryItems,
    int days = 5,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock meal plans
    final plans = <MealPlan>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      plans.add(MealPlan(
        date: now.add(Duration(days: i)),
        breakfast: _mockMeals[i % _mockMeals.length],
        lunch: _mockMeals[(i + 1) % _mockMeals.length],
        dinner: _mockMeals[(i + 2) % _mockMeals.length],
      ));
    }

    return plans;
  }

  static List<Meal> getMealsByCuisine(String cuisine) {
    return _mockMeals.where((meal) => meal.cuisine == cuisine).toList();
  }
}