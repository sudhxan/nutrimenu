@echo off
echo Setting up NutriMenu Flutter App...
echo.

:: Create directory structure
echo Creating directory structure...
mkdir lib\models 2>nul
mkdir lib\screens\onboarding 2>nul
mkdir lib\screens\home 2>nul
mkdir lib\services 2>nul
mkdir lib\widgets 2>nul
mkdir lib\theme 2>nul

echo ✓ Directory structure created
echo.

:: Create empty files
echo Creating empty files...
type nul > lib\main.dart
type nul > lib\models\user_profile.dart
type nul > lib\models\meal.dart
type nul > lib\models\meal_plan.dart
type nul > lib\models\grocery_item.dart
type nul > lib\screens\onboarding\onboarding_screen.dart
type nul > lib\screens\home\home_screen.dart
type nul > lib\services\storage_service.dart
type nul > lib\services\meal_service.dart
type nul > lib\services\image_service.dart
type nul > lib\widgets\custom_button.dart
type nul > lib\widgets\meal_card.dart
type nul > lib\widgets\nutrition_summary.dart
type nul > lib\theme\app_theme.dart

echo ✓ Files created
echo.

echo Setup complete! Now you need to:
echo 1. Copy the code from each artifact into the corresponding file
echo 2. Replace pubspec.yaml content
echo 3. Run: flutter pub get
echo 4. Configure platform permissions
echo 5. Run: flutter run

pause