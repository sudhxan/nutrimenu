// services/image_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'gemini_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Process grocery bill using Gemini AI
  static Future<List<String>> processGroceryBill(File image) async {
    try {
      // Use Gemini AI to analyze the grocery bill
      final items = await GeminiService.analyzeGroceryBill(image);
      return items;
    } catch (e) {
      // If Gemini service fails, throw the error message
      rethrow;
    }
  }

  /// Analyze food image for nutritional information
  static Future<Map<String, dynamic>> analyzeFoodNutrition(File image) async {
    try {
      final result = await GeminiService.analyzeFoodImage(image);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}