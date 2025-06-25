// utils/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'NutriMenu';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Smart Meal Planning';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRecipesPerRequest = 8;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // UI Constants
  static const double borderRadius = 16.0;
  static const double cardElevation = 4.0;
  static const double fabSize = 80.0;
  static const double swipeThreshold = 100.0;

  // Nutrition Defaults
  static const double defaultProteinGoal = 150.0;
  static const double defaultCaloriesGoal = 2000.0;
  static const int defaultMealPlanDays = 5;

  // Swipe Sensitivity
  static const double swipeVelocityThreshold = 1000.0;
  static const double maxRotationAngle = 0.3;

  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryGreen = Color(0xFF81C784);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  // Meal Type Colors
  static const Map<String, Color> mealTypeColors = {
    'breakfast': Color(0xFFFF9800), // Orange
    'lunch': Color(0xFF4CAF50),     // Green  
    'dinner': Color(0xFF3F51B5),    // Indigo
    'snack': Color(0xFFE91E63),     // Pink
  };

  // Meal Type Emojis
  static const Map<String, String> mealTypeEmojis = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙',
    'snack': '🍎',
  };

  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String apiError = 'Failed to generate recipes. Please try again';
  static const String imageError = 'Failed to process image. Please try another photo';
  static const String permissionError = 'Camera permission is required to scan images';

  // Success Messages
  static const String recipeGeneratedSuccess = 'Recipes generated successfully!';
  static const String mealPlanCreatedSuccess = 'Meal plan created successfully!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';

  // Shared Preferences Keys
  static const String onboardingCompletedKey = 'hasCompletedOnboarding';
  static const String userProfileKey = 'userProfile';
  static const String acceptedRecipesKey = 'acceptedRecipes';
  static const String mealPlansKey = 'mealPlans';

  // Default Recipe Categories
  static const List<String> defaultCuisines = [
    'Italian',
    'Chinese', 
    'Indian',
    'American',
    'Mexican',
    'Japanese',
    'Thai',
    'Mediterranean',
  ];

  static const List<String> defaultRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Kosher',
    'Low-Carb',
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Easy',
    'Medium', 
    'Hard',
  ];

  // Preparation Time Ranges
  static const Map<String, int> prepTimeRanges = {
    'Quick': 15,
    'Medium': 30,
    'Long': 60,
  };

  // Validation Rules
  static const double minHeight = 100.0;
  static const double maxHeight = 300.0;
  static const double minWeight = 30.0;
  static const double maxWeight = 300.0;
  static const double minProteinGoal = 20.0;
  static const double maxProteinGoal = 300.0;

  // Image Processing
  static const int imageQuality = 85;
  static const double maxImageWidth = 1080.0;
  static const double maxImageHeight = 1080.0;

  // Recipe Generation Prompts
  static const String baseGroceryBillPrompt = '''
Analyze this grocery bill/receipt image and extract all food items purchased. 
Based on these ingredients, create healthy and delicious recipe suggestions.
''';

  static const String baseRefrigeratorPrompt = '''
Analyze this refrigerator/pantry image and identify all visible food items and ingredients. 
Based on what's available, create recipe suggestions using these ingredients.
''';

  static const String nutritionRequirementsPrompt = '''
USER NUTRITION REQUIREMENTS:
- Daily Protein Goal: {proteinGoal}g
- Height: {height}{unit}
- Weight: {weight}{unit}
- Unit System: {unitSystem}
''';

  static const String responseFormatPrompt = '''
RESPONSE FORMAT REQUIREMENTS:
Return ONLY a valid JSON array with exactly this structure for each recipe:

[
  {
    "id": "unique_recipe_id",
    "name": "Recipe Name",
    "description": "Brief appetizing description (2-3 sentences)",
    "mealType": "breakfast|lunch|dinner|snack",
    "ingredients": ["ingredient 1", "ingredient 2", "ingredient 3"],
    "instructions": ["step 1", "step 2", "step 3"],
    "protein": 25.5,
    "calories": 450,
    "carbs": 35.2,
    "fats": 15.8,
    "prepTime": 30,
    "difficulty": "Easy|Medium|Hard",
    "tags": ["tag1", "tag2"]
  }
]
''';
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String recipeSwipe = '/recipe-swipe';
  static const String editProfile = '/edit-profile';
  static const String mealPlan = '/meal-plan';
  static const String nutrition = '/nutrition';
}

class AppAssets {
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
  
  // Patterns
  static const String foodPatternPath = 'assets/patterns/food_pattern.png';
  
  // Icons
  static const String groceryIconPath = 'assets/icons/grocery.png';
  static const String fridgeIconPath = 'assets/icons/fridge.png';
  
  // Fonts
  static const String primaryFont = 'Inter';
}

class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppSizes {
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double cardHeight = 200.0;
  static const double appBarHeight = 56.0;
}

// Extension to add convenient methods
extension AppConstantsExtension on AppConstants {
  static Color getMealTypeColor(String mealType) {
    return mealTypeColors[mealType.toLowerCase()] ?? AppConstants.primaryGreen;
  }

  static String getMealTypeEmoji(String mealType) {
    return mealTypeEmojis[mealType.toLowerCase()] ?? '🍽️';
  }

  static bool isValidHeight(double height, bool isMetric) {
    if (isMetric) {
      return height >= 100 && height <= 250; // cm
    } else {
      return height >= 3 && height <= 8; // feet
    }
  }

  static bool isValidWeight(double weight, bool isMetric) {
    if (isMetric) {
      return weight >= 30 && weight <= 300; // kg
    } else {
      return weight >= 66 && weight <= 660; // pounds
    }
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}