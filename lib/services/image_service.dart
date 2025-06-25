// services/image_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  // Legacy method - now returns mock data for compatibility
  static Future<List<String>> processGroceryBill(File image) async {
    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 3));
    
    // Return mock grocery items
    return [
      'Chicken Breast',
      'Spinach',
      'Tomatoes',
      'Rice',
      'Eggs',
      'Milk',
      'Bread',
      'Avocado',
      'Salmon',
      'Greek Yogurt',
    ];
  }

  // Additional utility methods
  static Future<bool> isImageValid(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return bytes.isNotEmpty && bytes.length < 5 * 1024 * 1024; // 5MB limit
    } catch (e) {
      return false;
    }
  }

  static Future<File?> compressImage(File image) async {
    // In a real app, you might use packages like flutter_image_compress
    // For now, just return the original image
    return image;
  }
}