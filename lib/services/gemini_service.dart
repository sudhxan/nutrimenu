// services/gemini_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    return key;
  }
  
  static GenerativeModel? _model;
  
  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
    return _model!;
  }

  /// Analyze grocery bill image and extract items
  static Future<List<String>> analyzeGroceryBill(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = '''
      Analyze this grocery receipt/bill image and extract all food items mentioned.
      Return ONLY a simple list of food items, one per line, without quantities, prices, or other details.
      Focus on actual food items that can be used for meal planning.
      Examples: Chicken Breast, Spinach, Tomatoes, Rice, Eggs, Milk, Bread, Avocado
      
      Do not include:
      - Non-food items
      - Quantities or measurements
      - Prices
      - Store information
      - Any formatting or extra text
      
      Just return the food items, one per line.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        throw Exception('No response from Gemini API');
      }

      // Parse the response and clean up the list
      final items = text
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && !item.startsWith('-') && !item.startsWith('*'))
          .map((item) => item.replaceAll(RegExp(r'^[\d\-\*\•\·\▪\▫\‣\⁃\◦\‧\⁌\⁍\‣\⁃\⁌\⁍\◦\‧\▪\▫\‣\⁃]+\s*'), ''))
          .where((item) => item.isNotEmpty)
          .take(15) // Limit to 15 items
          .toList();

      return items.isEmpty ? ['No food items detected'] : items;
      
    } catch (e) {
      throw Exception('Service temporarily unavailable. Please try again later.');
    }
  }

  /// Generate meal suggestions based on available ingredients and user profile
  static Future<Map<String, dynamic>> generateMealSuggestions({
    required List<String> groceryItems,
    required double proteinGoal,
    required List<String> cuisinePreferences,
    required List<String> dietaryRestrictions,
    int days = 5,
  }) async {
    try {
      final restrictionsText = dietaryRestrictions.isEmpty 
          ? 'No dietary restrictions' 
          : dietaryRestrictions.join(', ');
      
      final cuisinesText = cuisinePreferences.isEmpty 
          ? 'Any cuisine' 
          : cuisinePreferences.join(', ');

      final prompt = '''
      Create a $days-day meal plan using these available ingredients: ${groceryItems.join(', ')}
      
      Requirements:
      - Daily protein goal: ${proteinGoal}g
      - Preferred cuisines: $cuisinesText
      - Dietary restrictions: $restrictionsText
      - Include breakfast, lunch, and dinner for each day
      - Focus on using the available ingredients
      - Provide estimated protein and calories for each meal
      
      Return the response in this exact JSON format:
      {
        "mealPlan": [
          {
            "day": 1,
            "breakfast": {
              "name": "Meal Name",
              "ingredients": ["ingredient1", "ingredient2"],
              "protein": 25,
              "calories": 350,
              "prepTime": 15,
              "cuisine": "American",
              "difficulty": "Easy"
            },
            "lunch": {
              "name": "Meal Name",
              "ingredients": ["ingredient1", "ingredient2"],
              "protein": 30,
              "calories": 450,
              "prepTime": 20,
              "cuisine": "Italian",
              "difficulty": "Medium"
            },
            "dinner": {
              "name": "Meal Name",
              "ingredients": ["ingredient1", "ingredient2"],
              "protein": 35,
              "calories": 500,
              "prepTime": 30,
              "cuisine": "Asian",
              "difficulty": "Medium"
            }
          }
        ]
      }
      
      Make sure to:
      1. Use realistic protein and calorie values
      2. Keep prep times reasonable (5-45 minutes)
      3. Match cuisines to the actual meal styles
      4. Use difficulty levels: Easy, Medium, Hard
      5. Prioritize using the available ingredients
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        throw Exception('No response from Gemini API');
      }

      // Try to parse JSON from the response
      String jsonText = text;
      
      // Extract JSON if it's wrapped in markdown code blocks
      final jsonMatch = RegExp(r'```json\s*(.*?)\s*```', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        jsonText = jsonMatch.group(1) ?? text;
      }
      
      // If no JSON block found, try to find JSON in the text
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        jsonText = text.substring(jsonStart, jsonEnd);
      }

      try {
        // Note: In a real implementation, you'd parse this JSON properly
        // For now, we'll return a structured response that matches our models
        return {
          'success': true,
          'rawResponse': jsonText,
        };
      } catch (parseError) {
        throw Exception('Unable to parse meal plan response');
      }
      
    } catch (e) {
      throw Exception('Service temporarily unavailable. Please try again later.');
    }
  }

  /// Analyze food image for nutritional information
  static Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      const prompt = '''
      Analyze this food image and provide nutritional information.
      Estimate the following for the food shown:
      - Food name/type
      - Approximate protein content (in grams)
      - Approximate calories
      - Main nutrients present
      
      Return a brief, helpful response about the nutritional content.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        throw Exception('No response from Gemini API');
      }

      return {
        'success': true,
        'analysis': text,
      };
      
    } catch (e) {
      throw Exception('Service temporarily unavailable. Please try again later.');
    }
  }

  /// Check if the service is available
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await model.generateContent([
        Content.text('Hello, are you working?')
      ]);
      return response.text != null;
    } catch (e) {
      return false;
    }
  }
}