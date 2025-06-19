// models/meal_plan.dart
class MealPlan {
  final DateTime date;
  final Meal? breakfast;
  final Meal? lunch;
  final Meal? dinner;

  MealPlan({
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  double get totalProtein {
    double total = 0;
    if (breakfast != null) total += breakfast!.protein;
    if (lunch != null) total += lunch!.protein;
    if (dinner != null) total += dinner!.protein;
    return total;
  }

  double get totalCalories {
    double total = 0;
    if (breakfast != null) total += breakfast!.calories;
    if (lunch != null) total += lunch!.calories;
    if (dinner != null) total += dinner!.calories;
    return total;
  }
}