// widgets/recipe_swipe_card.dart
import 'package:flutter/material.dart';
import '../models/recipe_card.dart';
import '../screens/recipe/recipe_swipe_screen.dart';

class RecipeSwipeCard extends StatelessWidget {
  final RecipeCard recipe;
  final bool isInteractive;
  final SwipeDirection swipeDirection;

  const RecipeSwipeCard({
    Key? key,
    required this.recipe,
    this.isInteractive = true,
    this.swipeDirection = SwipeDirection.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  _buildImageSection(context),
                  
                  // Content section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildContentSection(context),
                    ),
                  ),
                ],
              ),
              
              // Swipe indicators
              if (swipeDirection != SwipeDirection.none)
                _buildSwipeIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recipe.mealTypeColor.withOpacity(0.8),
            recipe.mealTypeColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/patterns/food_pattern.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          
          // Content overlay
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Meal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${recipe.mealTypeEmoji} ${recipe.mealType.toUpperCase()}',
                      style: TextStyle(
                        color: recipe.mealTypeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Recipe name
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Quick info
                  Row(
                    children: [
                      _buildQuickInfo(
                        Icons.timer,
                        '${recipe.prepTime} min',
                      ),
                      const SizedBox(width: 16),
                      _buildQuickInfo(
                        Icons.restaurant,
                        recipe.difficulty,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(
          recipe.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 20),
        
        // Nutrition highlights
        Row(
          children: [
            _buildNutritionChip(
              'Protein',
              '${recipe.protein.toStringAsFixed(0)}g',
              Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildNutritionChip(
              'Calories',
              '${recipe.calories.toStringAsFixed(0)}',
              Colors.orange,
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Ingredients preview
        const Text(
          'Key Ingredients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: recipe.ingredients.take(4).map((ingredient) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ingredient,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        ),
        
        if (recipe.ingredients.length > 4) ...[
          const SizedBox(height: 8),
          Text(
            '+${recipe.ingredients.length - 4} more ingredients',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Swipe hint (only for first card)
        if (isInteractive)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swipe,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Swipe right to accept • Swipe left to pass',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator(BuildContext context) {
    final isAccept = swipeDirection == SwipeDirection.right;
    final color = isAccept ? Colors.green : Colors.red;
    final icon = isAccept ? Icons.favorite : Icons.close;
    final text = isAccept ? 'LIKE' : 'PASS';
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}