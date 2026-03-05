import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NutritionPlanBuilderScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const NutritionPlanBuilderScreen({super.key, required this.onBackPressed});

  @override
  State<NutritionPlanBuilderScreen> createState() => _NutritionPlanBuilderScreenState();
}

class _NutritionPlanBuilderScreenState extends State<NutritionPlanBuilderScreen> {
  int protein = 150;
  int carbs = 200;
  int fat = 60;

  int get totalCalories => (protein * 4) + (carbs * 4) + (fat * 9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onBackPressed,
        ),
        title: const Text('New Nutrition Plan'),
        actions: [
          TextButton(
            onPressed: widget.onBackPressed,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Plan Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            
            // Macros Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroCircle('Protein', protein, 'g', AppColors.primary),
                  _buildMacroCircle('Carbs', carbs, 'g', AppColors.warning),
                  _buildMacroCircle('Fat', fat, 'g', AppColors.error),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Total: $totalCalories kcal',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 32),

            // Sliders
            const Text('Adjust Macros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSlider('Protein (g)', protein, AppColors.primary, (val) => setState(() => protein = val.toInt())),
            _buildSlider('Carbs (g)', carbs, AppColors.warning, (val) => setState(() => carbs = val.toInt())),
            _buildSlider('Fat (g)', fat, AppColors.error, (val) => setState(() => fat = val.toInt())),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Add Meal functionality
              },
              icon: const Icon(Icons.restaurant),
              label: const Text('Add Meal'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCircle(String label, int amount, String unit, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: 1.0,
                color: color.withOpacity(0.2),
                strokeWidth: 6,
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: 0.7, // Visual placeholder
                color: color,
                strokeWidth: 6,
              ),
            ),
            Text(
              '$amount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildSlider(String label, int value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 400,
          activeColor: color,
          inactiveColor: AppColors.surface,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
