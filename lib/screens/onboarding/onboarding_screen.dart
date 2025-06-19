import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  final _userProfile = UserProfile();
  
  // Form controllers
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _proteinGoalController = TextEditingController();
  
  // Height unit toggle
  bool _isMetric = true;
  
  // Selected items
  final Set<String> _selectedCuisines = {};
  final Set<String> _selectedRestrictions = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _proteinGoalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    _userProfile.height = double.tryParse(_heightController.text) ?? 0;
    _userProfile.weight = double.tryParse(_weightController.text) ?? 0;
    _userProfile.proteinGoal = double.tryParse(_proteinGoalController.text) ?? 0;
    _userProfile.isMetric = _isMetric;
    _userProfile.cuisines = _selectedCuisines.toList();
    _userProfile.restrictions = _selectedRestrictions.toList();
    
    await StorageService.saveUserProfile(_userProfile);
    await StorageService.setOnboardingCompleted();
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
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
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildBodyMetricsPage(),
                    _buildCuisinePreferencesPage(),
                    _buildDietaryRestrictionsPage(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == _currentPage ? 40 : 20,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= _currentPage
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Welcome to NutriMenu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal meal planning assistant that helps you meet your nutrition goals',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildFeatureItem(
              Icons.camera_alt,
              'Scan Grocery Bills',
              'Take a photo and get meal suggestions',
            ),
            _buildFeatureItem(
              Icons.fitness_center,
              'Track Protein Goals',
              'Meet your daily protein requirements',
            ),
            _buildFeatureItem(
              Icons.calendar_today,
              '5-Day Meal Plans',
              'Get personalized meal suggestions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Let\'s personalize your experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your body metrics and protein goals',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          
          // Unit toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUnitToggle('Metric', _isMetric, () {
                setState(() => _isMetric = true);
              }),
              const SizedBox(width: 16),
              _buildUnitToggle('Imperial', !_isMetric, () {
                setState(() => _isMetric = false);
              }),
            ],
          ),
          const SizedBox(height: 32),
          
          // Height input
          _buildInputField(
            controller: _heightController,
            label: 'Height',
            suffix: _isMetric ? 'cm' : 'ft',
            icon: Icons.height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          
          // Weight input
          _buildInputField(
            controller: _weightController,
            label: 'Weight',
            suffix: _isMetric ? 'kg' : 'lbs',
            icon: Icons.monitor_weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          
          // Protein goal input
          _buildInputField(
            controller: _proteinGoalController,
            label: 'Daily Protein Goal',
            suffix: 'g',
            icon: Icons.fitness_center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recommended: 0.8-1g protein per kg body weight',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinePreferencesPage() {
    final cuisines = [
      {'name': 'Italian', 'emoji': '🍝'},
      {'name': 'Chinese', 'emoji': '🥟'},
      {'name': 'Indian', 'emoji': '🍛'},
      {'name': 'American', 'emoji': '🍔'},
      {'name': 'Mexican', 'emoji': '🌮'},
      {'name': 'Japanese', 'emoji': '🍱'},
      {'name': 'Thai', 'emoji': '🍜'},
      {'name': 'Mediterranean', 'emoji': '🥙'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Choose your favorite cuisines',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more cuisines you enjoy',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cuisines.map((cuisine) {
              final isSelected = _selectedCuisines.contains(cuisine['name']);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCuisines.remove(cuisine['name']);
                    } else {
                      _selectedCuisines.add(cuisine['name']!);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cuisine['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cuisine['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryRestrictionsPage() {
    final restrictions = [
      {'name': 'Vegetarian', 'icon': Icons.eco},
      {'name': 'Vegan', 'icon': Icons.nature},
      {'name': 'Gluten-Free', 'icon': Icons.no_meals},
      {'name': 'Dairy-Free', 'icon': Icons.free_breakfast},
      {'name': 'Nut-Free', 'icon': Icons.do_not_disturb},
      {'name': 'Halal', 'icon': Icons.restaurant},
      {'name': 'Kosher', 'icon': Icons.star},
      {'name': 'Low-Carb', 'icon': Icons.bakery_dining},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Any dietary restrictions?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply (optional)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ...restrictions.map((restriction) {
            final isSelected = _selectedRestrictions.contains(restriction['name']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedRestrictions.remove(restriction['name']);
                    } else {
                      _selectedRestrictions.add(restriction['name'] as String);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        restriction['icon'] as IconData,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          restriction['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final bool canProceed = _currentPage == 0 ||
        (_currentPage == 1 &&
            _heightController.text.isNotEmpty &&
            _weightController.text.isNotEmpty &&
            _proteinGoalController.text.isNotEmpty) ||
        (_currentPage == 2 && _selectedCuisines.isNotEmpty) ||
        _currentPage == 3;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            const SizedBox(width: 80),
          CustomButton(
            text: _currentPage == 3 ? 'Get Started' : 'Next',
            onPressed: canProceed ? _nextPage : null,
            width: 120,
          ),
        ],
      ),
    );
  }
}