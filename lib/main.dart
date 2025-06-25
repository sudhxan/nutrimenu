// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/storage_service.dart';
import 'services/gemini_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Test Gemini API connection on startup
  _testGeminiConnection();
  
  runApp(const NutriMenuApp());
}

void _testGeminiConnection() async {
  try {
    final isConnected = await GeminiService.testConnection();
    print('Gemini API Connection: ${isConnected ? 'Success' : 'Failed'}');
    
    if (!isConnected) {
      print('Warning: Gemini API not configured. Using mock data.');
      print('Please set your API key in services/gemini_service.dart');
    }
  } catch (e) {
    print('Gemini API test failed: $e');
  }
}

class NutriMenuApp extends StatelessWidget {
  const NutriMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriMenu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      // Add route handling for better navigation
      routes: {
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // Show splash for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    final hasCompletedOnboarding = await StorageService.hasCompletedOnboarding();
    
    if (!mounted) return;
    
    // Use named route for better navigation
    final String route = hasCompletedOnboarding ? '/home' : '/onboarding';
    
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo/icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // App name
                      const Text(
                        'NutriMenu',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tagline
                      Text(
                        'AI-Powered Meal Planning',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}