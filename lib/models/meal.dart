// models/meal.dart
class Meal {
  final String id;
  final String name;
  final String cuisine;
  final double protein;
  final double calories;
  final double carbs;
  final double fats;
  final List<String> ingredients;
  final String imageUrl;
  final int prepTime;
  final String difficulty;

  Meal({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.protein,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.imageUrl,
    required this.prepTime,
    required this.difficulty,
  });
}