// screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({
    Key? key,
    required this.userProfile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _proteinGoalController;
  late bool _isMetric;
  late Set<String> _selectedCuisines;
  late Set<String> _selectedRestrictions;
  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.userProfile.height.toString());
    _weightController = TextEditingController(text: widget.userProfile.weight.toString());
    _proteinGoalController = TextEditingController(text: widget.userProfile.proteinGoal.toString());
    _isMetric = widget.userProfile.isMetric;
    _selectedCuisines = Set.from(widget.userProfile.cuisines);
    _selectedRestrictions = Set.from(widget.userProfile.restrictions);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _proteinGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    final updatedProfile = UserProfile(
      height: double.tryParse(_heightController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      proteinGoal: double.tryParse(_proteinGoalController.text) ?? 0,
      isMetric: _isMetric,
      cuisines: _selectedCuisines.toList(),
      restrictions: _selectedRestrictions.toList(),
    );

    await StorageService.saveUserProfile(updatedProfile);

    if (!mounted) return;

    Navigator.pop(context, updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Body Metrics Section
              _buildSectionTitle('Body Metrics'),
              const SizedBox(height: 16),
              
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
              const SizedBox(height: 24),
              
              // Height input
              _buildInputField(
                controller: _heightController,
                label: 'Height',
                suffix: _isMetric ? 'cm' : 'ft',
                icon: Icons.height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              
              // Weight input
              _buildInputField(
                controller: _weightController,
                label: 'Weight',
                suffix: _isMetric ? 'kg' : 'lbs',
                icon: Icons.monitor_weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              
              // Protein goal input
              _buildInputField(
                controller: _proteinGoalController,
                label: 'Daily Protein Goal',
                suffix: 'g',
                icon: Icons.fitness_center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: 32),
              
              // Cuisines Section
              _buildSectionTitle('Favorite Cuisines'),
              const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cuisine['emoji']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cuisine['name']!,
                            style: TextStyle(
                              fontSize: 14,
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
              
              const SizedBox(height: 32),
              
              // Dietary Restrictions Section
              _buildSectionTitle('Dietary Restrictions'),
              const SizedBox(height: 16),
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                            size: 24,
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
              
              const SizedBox(height: 40),
              
              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
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
}