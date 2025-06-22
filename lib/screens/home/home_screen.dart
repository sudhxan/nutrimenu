// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_profile.dart';
import '../../models/meal_plan.dart';
import '../../services/storage_service.dart';
import '../../services/image_service.dart';
import '../../services/meal_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/nutrition_summary.dart';
import '../profile/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _userProfile;
  List<MealPlan> _mealPlans = [];
  bool _isLoading = false;
  File? _selectedImage;
  List<String> _detectedGroceries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await StorageService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _scanGroceryBill() async {
    final image = await ImageService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isLoading = true;
      });

      try {
        final groceries = await ImageService.processGroceryBill(image);
        setState(() {
          _detectedGroceries = groceries;
        });

        if (_userProfile != null) {
          final plans = await MealService.generateMealPlan(
            profile: _userProfile!,
            groceryItems: groceries,
          );
          setState(() {
            _mealPlans = plans;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to process image');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isLoading = true;
      });

      try {
        final groceries = await ImageService.processGroceryBill(image);
        setState(() {
          _detectedGroceries = groceries;
        });

        if (_userProfile != null) {
          final plans = await MealService.generateMealPlan(
            profile: _userProfile!,
            groceryItems: groceries,
          );
          setState(() {
            _mealPlans = plans;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to process image');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  double _calculateTodayProtein() {
    if (_mealPlans.isEmpty) return 0;
    return _mealPlans.first.totalProtein;
  }

  double _calculateTodayCalories() {
    if (_mealPlans.isEmpty) return 0;
    return _mealPlans.first.totalCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_userProfile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NutritionSummary(
                  currentProtein: _calculateTodayProtein(),
                  targetProtein: _userProfile!.proteinGoal,
                  calories: _calculateTodayCalories(),
                ),
              ),
            const SizedBox(height: 20),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildScanTab(),
                  _buildMealPlanTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Let\'s plan your meals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: Theme.of(context).primaryColor,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: const [
          Tab(text: 'Scan'),
          Tab(text: 'Meal Plan'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_selectedImage == null) ...[
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan your grocery bill',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a photo to generate meal plans',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_detectedGroceries.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Detected ${_detectedGroceries.length} items',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _detectedGroceries.map((item) {
                        return Chip(
                          label: Text(item),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.green.shade300),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Camera',
                  icon: Icons.camera_alt,
                  onPressed: _isLoading ? null : _scanGroceryBill,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Gallery',
                  icon: Icons.photo_library,
                  onPressed: _isLoading ? null : _pickFromGallery,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          if (_isLoading) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text(
              'Analyzing your groceries...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealPlanTab() {
    if (_mealPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No meal plans yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a grocery bill to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mealPlans.length,
      itemBuilder: (context, index) {
        final plan = _mealPlans[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(plan.date),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (plan.breakfast != null) ...[
              _buildMealSection('Breakfast', plan.breakfast!),
              const SizedBox(height: 12),
            ],
            if (plan.lunch != null) ...[
              _buildMealSection('Lunch', plan.lunch!),
              const SizedBox(height: 12),
            ],
            if (plan.dinner != null) ...[
              _buildMealSection('Dinner', plan.dinner!),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildMealSection(String mealType, meal) {
    return MealCard(
      meal: meal,
      onTap: () {
        // Navigate to meal details
      },
    );
  }

  Widget _buildProfileTab() {
    if (_userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileItem(
            'Height',
            '${_userProfile!.height} ${_userProfile!.isMetric ? 'cm' : 'ft'}',
            Icons.height,
          ),
          _buildProfileItem(
            'Weight',
            '${_userProfile!.weight} ${_userProfile!.isMetric ? 'kg' : 'lbs'}',
            Icons.monitor_weight,
          ),
          _buildProfileItem(
            'Daily Protein Goal',
            '${_userProfile!.proteinGoal}g',
            Icons.fitness_center,
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            'Favorite Cuisines',
            _userProfile!.cuisines,
            Icons.restaurant,
          ),
          if (_userProfile!.restrictions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildProfileSection(
              'Dietary Restrictions',
              _userProfile!.restrictions,
              Icons.no_meals,
            ),
          ],
          const SizedBox(height: 32),
          CustomButton(
            text: 'Edit Profile',
            onPressed: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userProfile: _userProfile!,
                  ),
                ),
              );
              
              if (updatedProfile != null) {
                setState(() {
                  _userProfile = updatedProfile;
                });
              }
            },
            icon: Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<String> items, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Chip(
                label: Text(item),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                side: BorderSide(color: Theme.of(context).primaryColor),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final dayName = days[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$dayName, ${date.day} $month';
  }
}