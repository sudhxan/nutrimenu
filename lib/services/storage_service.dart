// services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _onboardingKey = 'hasCompletedOnboarding';
  static const String _userProfileKey = 'userProfile';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(profile.toJson());
    await prefs.setString(_userProfileKey, jsonString);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString);
      return UserProfile.fromJson(jsonMap);
    }
    return null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}