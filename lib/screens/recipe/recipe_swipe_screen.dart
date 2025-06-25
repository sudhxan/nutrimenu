// screens/recipe/recipe_swipe_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/recipe_card.dart';
import '../../widgets/recipe_swipe_card.dart';

enum SwipeDirection { left, right, none }

class RecipeSwipeScreen extends StatefulWidget {
  final List<RecipeCard> recipes;
  final Function(List<RecipeCard>) onRecipesAccepted;

  const RecipeSwipeScreen({
    Key? key,
    required this.recipes,
    required this.onRecipesAccepted,
  }) : super(key: key);

  @override
  State<RecipeSwipeScreen> createState() => _RecipeSwipeScreenState();
}

class _RecipeSwipeScreenState extends State<RecipeSwipeScreen>
    with TickerProviderStateMixin {
  late List<RecipeCard> _recipes;
  List<RecipeCard> _acceptedRecipes = [];
  List<RecipeCard> _rejectedRecipes = [];
  int _currentIndex = 0;
  
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _recipes = List.from(widget.recipes);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _scaleController.reverse();
    
    const threshold = 100.0;
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    if (_dragOffset.dx.abs() > threshold || velocity.abs() > 1000) {
      // Determine swipe direction
      final isSwipeRight = _dragOffset.dx > 0 || velocity > 0;
      _animateCard(isSwipeRight);
    } else {
      // Snap back to center
      _resetCard();
    }
  }

  void _animateCard(bool isAccepted) {
    final direction = isAccepted ? 1.0 : -1.0;
    final targetOffset = Offset(direction * MediaQuery.of(context).size.width, 0);
    
    _animationController.reset();
    final animation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _dragOffset = animation.value;
      });
    });
    
    _animationController.forward().then((_) {
      _handleSwipe(isAccepted);
    });
  }

  void _resetCard() {
    _animationController.reset();
    final animation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _dragOffset = animation.value;
      });
    });
    
    _animationController.forward().then((_) {
      setState(() {
        _isDragging = false;
      });
    });
  }

  void _handleSwipe(bool isAccepted) {
    final currentRecipe = _recipes[_currentIndex];
    
    if (isAccepted) {
      _acceptedRecipes.add(currentRecipe);
    } else {
      _rejectedRecipes.add(currentRecipe);
    }
    
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
    
    if (_currentIndex >= _recipes.length) {
      _completeSwipeSession();
    }
  }

  void _completeSwipeSession() {
    widget.onRecipesAccepted(_acceptedRecipes);
    Navigator.pop(context);
  }

  void _swipeLeft() {
    _animateCard(false);
  }

  void _swipeRight() {
    _animateCard(true);
  }

  double get _rotation {
    const maxRotation = 0.3;
    return (_dragOffset.dx / MediaQuery.of(context).size.width) * maxRotation;
  }

  double get _opacity {
    const maxOpacity = 0.8;
    return (1.0 - (_dragOffset.dx.abs() / MediaQuery.of(context).size.width))
        .clamp(maxOpacity, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Recipe Suggestions (${_currentIndex + 1}/${_recipes.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _completeSwipeSession,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _recipes.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          // Cards stack
          Expanded(
            child: _currentIndex < _recipes.length
                ? _buildCardStack()
                : _buildCompletionScreen(),
          ),
          
          // Action buttons
          if (_currentIndex < _recipes.length) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return Stack(
      children: [
        // Next card (background)
        if (_currentIndex + 1 < _recipes.length)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * _scaleAnimation.value),
                    child: RecipeSwipeCard(
                      recipe: _recipes[_currentIndex + 1],
                      isInteractive: false,
                    ),
                  );
                },
              ),
            ),
          ),
        
        // Current card (foreground)
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Transform.translate(
                offset: _dragOffset,
                child: Transform.rotate(
                  angle: _rotation,
                  child: Opacity(
                    opacity: _opacity,
                    child: RecipeSwipeCard(
                      recipe: _recipes[_currentIndex],
                      isInteractive: true,
                      swipeDirection: _dragOffset.dx > 50
                          ? SwipeDirection.right
                          : _dragOffset.dx < -50
                              ? SwipeDirection.left
                              : SwipeDirection.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reject button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: _swipeLeft,
            heroTag: "reject",
          ),
          
          // Info button
          _buildActionButton(
            icon: Icons.info_outline,
            color: Colors.blue,
            onPressed: () => _showRecipeDetails(_recipes[_currentIndex]),
            heroTag: "info",
          ),
          
          // Accept button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: _swipeRight,
            heroTag: "accept",
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'Great choices!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You accepted ${_acceptedRecipes.length} recipes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _completeSwipeSession,
            child: const Text('Create Meal Plan'),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(RecipeCard recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Recipe title and meal type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: recipe.mealTypeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${recipe.mealTypeEmoji} ${recipe.mealType.toUpperCase()}',
                          style: TextStyle(
                            color: recipe.mealTypeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    recipe.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nutrition info
                  _buildNutritionGrid(recipe),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredients
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionGrid(RecipeCard recipe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildNutritionItem('Protein', '${recipe.protein.toStringAsFixed(0)}g', Colors.blue),
          _buildNutritionItem('Calories', '${recipe.calories.toStringAsFixed(0)}', Colors.orange),
          _buildNutritionItem('Carbs', '${recipe.carbs.toStringAsFixed(0)}g', Colors.green),
          _buildNutritionItem('Fat', '${recipe.fats.toStringAsFixed(0)}g', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}