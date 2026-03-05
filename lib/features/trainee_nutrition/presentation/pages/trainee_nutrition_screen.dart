import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TraineeNutritionScreen extends StatelessWidget {
  const TraineeNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroTracker('Calories', '1450', '2200 kcal', AppColors.primary),
                  _buildMacroTracker('Protein', '85', '160 g', AppColors.success),
                  _buildMacroTracker('Carbs', '120', '200 g', AppColors.warning),
                  _buildMacroTracker('Fat', '45', '70 g', AppColors.error),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Target: 2200 kcal', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildMealCard('Breakfast', 'Oatmeal & Protein Shake', '450 kcal', true),
            const SizedBox(height: 12),
            _buildMealCard('Lunch', 'Chicken Salad', '600 kcal', false),
            const SizedBox(height: 12),
            _buildMealCard('Dinner', 'Salmon & Asparagus', '700 kcal', false),
            const SizedBox(height: 12),
            _buildMealCard('Snacks', 'Greek Yogurt', '200 kcal', false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Food', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMacroTracker(String label, String current, String target, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: 1.0,
                color: color.withOpacity(0.2),
                strokeWidth: 4,
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: 0.6, // Mock value
                color: color,
                strokeWidth: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(current, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildMealCard(String title, String items, String kcal, bool isLogged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLogged ? AppColors.successLight : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLogged ? Icons.check : Icons.add,
              color: isLogged ? AppColors.success : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(items, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(kcal, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
