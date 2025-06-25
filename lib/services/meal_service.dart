// services/meal_service.dart
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../models/recipe_card.dart';

class MealService {
  // Enhanced method to create meal schedule from accepted recipes
  static Future<List<MealPlan>> createMealSchedule({
    required List<RecipeCard> recipes,
    required UserProfile userProfile,
    int days = 5,
  }) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 1));

    // Group recipes by meal type
    final Map<String, List<RecipeCard>> recipesByMealType = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (final recipe in recipes) {
      final mealType = recipe.mealType.toLowerCase();
      if (recipesByMealType.containsKey(mealType)) {
        recipesByMealType[mealType]!.add(recipe);
      }
    }

    // Create meal plans for the specified number of days
    final List<MealPlan> mealPlans = [];
    final DateTime startDate = DateTime.now();

    for (int day = 0; day < days; day++) {
      final currentDate = startDate.add(Duration(days: day));
      
      final mealPlan = MealPlan(
        date: currentDate,
        breakfast: _selectMealForDay(recipesByMealType['breakfast']!, day)?.toMeal(),
        lunch: _selectMealForDay(recipesByMealType['lunch']!, day)?.toMeal(),
        dinner: _selectMealForDay(recipesByMealType['dinner']!, day)?.toMeal(),
      );

      mealPlans.add(mealPlan);
    }

    // Optimize nutrition across all days
    _optimizeNutritionAcrossDays(mealPlans, userProfile);

    return mealPlans;
  }

  // Select appropriate recipe for a specific day, ensuring variety
  static RecipeCard? _selectMealForDay(List<RecipeCard> recipes, int dayIndex) {
    if (recipes.isEmpty) return null;
    
    // Use modulo to cycle through recipes and ensure variety
    final index = dayIndex % recipes.length;
    return recipes[index];
  }

  // Optimize nutrition distribution across days
  static void _optimizeNutritionAcrossDays(List<MealPlan> mealPlans, UserProfile userProfile) {
    for (final plan in mealPlans) {
      final totalProtein = plan.totalProtein;
      final proteinGoal = userProfile.proteinGoal;
      
      // If protein is significantly below target, suggest adding snacks
      if (totalProtein < proteinGoal * 0.8) {
        // Logic to add high-protein snacks could go here
        // For now, we'll just log the deficit
        print('Day ${plan.date.day}: Protein deficit of ${(proteinGoal - totalProtein).toStringAsFixed(1)}g');
      }
    }
  }

  // Generate personalized meal suggestions based on user preferences
  static Future<List<Meal>> generatePersonalizedMeals({
    required UserProfile profile,
    required String mealType,
    int count = 3,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // This would typically call an AI service or database
    // For now, return curated meals based on preferences
    
    final List<Meal> allMeals = _getAllMeals();
    
    // Filter by user preferences
    List<Meal> filteredMeals = allMeals.where((meal) {
      // Check dietary restrictions
      if (profile.restrictions.contains('Vegetarian') && 
          (meal.ingredients.any((ingredient) => 
            ingredient.toLowerCase().contains('chicken') ||
            ingredient.toLowerCase().contains('beef') ||
            ingredient.toLowerCase().contains('fish')))) {
        return false;
      }
      
      if (profile.restrictions.contains('Vegan') &&
          (meal.ingredients.any((ingredient) =>
            ingredient.toLowerCase().contains('cheese') ||
            ingredient.toLowerCase().contains('milk') ||
            ingredient.toLowerCase().contains('egg')))) {
        return false;
      }
      
      // Check cuisine preferences
      if (profile.cuisines.isNotEmpty && 
          !profile.cuisines.contains(meal.cuisine)) {
        return false;
      }
      
      return true;
    }).toList();

    // If no meals match preferences, return some default options
    if (filteredMeals.isEmpty) {
      filteredMeals = allMeals.take(count).toList();
    }

    // Sort by protein content (prioritize high-protein meals)
    filteredMeals.sort((a, b) => b.protein.compareTo(a.protein));
    
    return filteredMeals.take(count).toList();
  }

  // Calculate daily nutrition targets based on user profile
  static Map<String, double> calculateNutritionTargets(UserProfile profile) {
    // Basic calculations based on user's weight and activity level
    // These are simplified - real apps would use more sophisticated formulas
    
    double weight = profile.weight;
    if (!profile.isMetric) {
      weight = weight * 0.453592; // Convert pounds to kg
    }
    
    // Rough estimates for maintenance calories and macros
    final double estimatedCalories = weight * 30; // Very rough estimate
    final double proteinGoal = profile.proteinGoal;
    final double carbsGoal = estimatedCalories * 0.45 / 4; // 45% of calories from carbs
    final double fatsGoal = estimatedCalories * 0.25 / 9; // 25% of calories from fats
    
    return {
      'calories': estimatedCalories,
      'protein': proteinGoal,
      'carbs': carbsGoal,
      'fats': fatsGoal,
    };
  }

  // Analyze nutrition gap between current meals and targets
  static Map<String, double> analyzeNutritionGap(
    List<MealPlan> mealPlans,
    UserProfile profile,
  ) {
    final targets = calculateNutritionTargets(profile);
    
    if (mealPlans.isEmpty) {
      return targets; // All nutrients are missing
    }
    
    // Calculate averages from meal plans
    double totalProtein = 0;
    double totalCalories = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    for (final plan in mealPlans) {
      totalProtein += plan.totalProtein;
      totalCalories += plan.totalCalories;
      
      // Calculate carbs and fats from meals
      if (plan.breakfast != null) {
        totalCarbs += plan.breakfast!.carbs;
        totalFats += plan.breakfast!.fats;
      }
      if (plan.lunch != null) {
        totalCarbs += plan.lunch!.carbs;
        totalFats += plan.lunch!.fats;
      }
      if (plan.dinner != null) {
        totalCarbs += plan.dinner!.carbs;
        totalFats += plan.dinner!.fats;
      }
    }
    
    final avgProtein = totalProtein / mealPlans.length;
    final avgCalories = totalCalories / mealPlans.length;
    final avgCarbs = totalCarbs / mealPlans.length;
    final avgFats = totalFats / mealPlans.length;
    
    return {
      'protein': (targets['protein']! - avgProtein).clamp(0.0, double.infinity),
      'calories': (targets['calories']! - avgCalories).clamp(0.0, double.infinity),
      'carbs': (targets['carbs']! - avgCarbs).clamp(0.0, double.infinity),
      'fats': (targets['fats']! - avgFats).clamp(0.0, double.infinity),
    };
  }

  // Get suggestions to fill nutrition gaps
  static List<String> getNutritionSuggestions(Map<String, double> nutritionGap) {
    final List<String> suggestions = [];
    
    if (nutritionGap['protein']! > 20) {
      suggestions.add('Add a protein shake or Greek yogurt snack');
      suggestions.add('Include more lean meats, fish, or legumes');
    }
    
    if (nutritionGap['calories']! > 300) {
      suggestions.add('Add healthy snacks like nuts or fruit');
      suggestions.add('Increase portion sizes of existing meals');
    }
    
    if (nutritionGap['carbs']! > 50) {
      suggestions.add('Include more whole grains and fruits');
      suggestions.add('Add oatmeal or quinoa to your meals');
    }
    
    if (nutritionGap['fats']! > 20) {
      suggestions.add('Include healthy fats like avocado and olive oil');
      suggestions.add('Add nuts, seeds, or fatty fish to your diet');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('Your nutrition looks well-balanced!');
    }
    
    return suggestions;
  }

  // Mock data - in a real app, this would come from a database
  static List<Meal> _getAllMeals() {
    return [
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
      Meal(
        id: '4',
        name: 'Quinoa Buddha Bowl',
        cuisine: 'American',
        protein: 18,
        calories: 380,
        carbs: 45,
        fats: 12,
        ingredients: ['Quinoa', 'Chickpeas', 'Vegetables', 'Tahini dressing'],
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 30,
        difficulty: 'Easy',
      ),
      Meal(
        id: '5',
        name: 'Salmon Teriyaki',
        cuisine: 'Japanese',
        protein: 40,
        calories: 450,
        carbs: 20,
        fats: 25,
        ingredients: ['Salmon', 'Teriyaki sauce', 'Rice', 'Broccoli'],
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 25,
        difficulty: 'Medium',
      ),
      Meal(
        id: '6',
        name: 'Veggie Stir Fry',
        cuisine: 'Chinese',
        protein: 12,
        calories: 320,
        carbs: 40,
        fats: 15,
        ingredients: ['Mixed vegetables', 'Tofu', 'Soy sauce', 'Ginger'],
        imageUrl: 'https://via.placeholder.com/300',
        prepTime: 15,
        difficulty: 'Easy',
      ),
    ];
  }

  // Legacy method for compatibility - enhanced version
  static Future<List<MealPlan>> generateMealPlan({
    required UserProfile profile,
    required List<String> groceryItems,
    int days = 5,
  }) async {
    // This is the original method, now enhanced
    await Future.delayed(const Duration(seconds: 2));

    final List<RecipeCard> mockRecipes = [];
    
    for (int index = 0; index < groceryItems.take(8).length; index++) {
      final item = groceryItems.elementAt(index);
      mockRecipes.add(RecipeCard(
        id: 'grocery_$index',
        name: 'Recipe with $item',
        description: 'A delicious recipe featuring $item',
        mealType: ['breakfast', 'lunch', 'dinner', 'snack'][index % 4],
        ingredients: [item, 'Other ingredients'],
        instructions: ['Cook the $item', 'Season to taste', 'Serve hot'],
        protein: (20 + (index * 5)).toDouble(),
        calories: (300 + (index * 50)).toDouble(),
        carbs: (30 + (index * 10)).toDouble(),
        fats: (15 + (index * 5)).toDouble(),
        prepTime: 20 + (index * 10),
        difficulty: ['Easy', 'Medium', 'Hard'][index % 3],
        tags: [item.toLowerCase()],
      ));
    }

    return createMealSchedule(
      recipes: mockRecipes,
      userProfile: profile,
      days: days,
    );
  }

  // Get meals by cuisine for compatibility
  static List<Meal> getMealsByCuisine(String cuisine) {
    return _getAllMeals().where((meal) => meal.cuisine == cuisine).toList();
  }
}