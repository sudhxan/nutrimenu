// models/grocery_item.dart
class GroceryItem {
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double? protein;
  final double? calories;

  GroceryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.protein,
    this.calories,
  });
}