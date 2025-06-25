// models/recipe_card.dart
import 'package:flutter/material.dart';
import 'meal.dart';

class RecipeCard {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String mealType; // breakfast, lunch, dinner, snack
  final int servings;
  final double protein;
  final double calories;
  final double carbs;
  final double fats;
  final int prepTime;
  final int cookTime;
  final int totalTime;
  final String difficulty;
  final List<String> tags;
  final List<String> cookingTips;
  final String storage;
  final String? imageUrl;

  RecipeCard({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.mealType,
    this.servings = 2,
    required this.protein,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.prepTime,
    this.cookTime = 0,
    this.totalTime = 0,
    required this.difficulty,
    required this.tags,
    this.cookingTips = const [],
    this.storage = '',
    this.imageUrl,
  });

  // Convert to Meal object for compatibility with existing code
  Meal toMeal() {
    return Meal(
      id: id,
      name: name,
      cuisine: tags.isNotEmpty ? tags.first : 'Unknown',
      protein: protein,
      calories: calories,
      carbs: carbs,
      fats: fats,
      ingredients: ingredients,
      imageUrl: imageUrl ?? 'https://via.placeholder.com/300',
      prepTime: prepTime,
      difficulty: difficulty,
    );
  }

  factory RecipeCard.fromJson(Map<String, dynamic> json) {
    return RecipeCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      mealType: json['mealType'] ?? 'snack',
      servings: json['servings'] ?? 2,
      protein: (json['protein'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      prepTime: json['prepTime'] ?? 30,
      cookTime: json['cookTime'] ?? 0,
      totalTime: json['totalTime'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      tags: List<String>.from(json['tags'] ?? []),
      cookingTips: List<String>.from(json['cookingTips'] ?? []),
      storage: json['storage'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'mealType': mealType,
      'servings': servings,
      'protein': protein,
      'calories': calories,
      'carbs': carbs,
      'fats': fats,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'totalTime': totalTime,
      'difficulty': difficulty,
      'tags': tags,
      'cookingTips': cookingTips,
      'storage': storage,
      'imageUrl': imageUrl,
    };
  }

  String get mealTypeEmoji {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  Color get mealTypeColor {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9800); // Orange
      case 'lunch':
        return const Color(0xFF4CAF50); // Green
      case 'dinner':
        return const Color(0xFF3F51B5); // Indigo
      case 'snack':
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}