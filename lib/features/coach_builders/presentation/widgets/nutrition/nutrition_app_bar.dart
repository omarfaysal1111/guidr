import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';

class NutritionBuilderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int currentStep;
  final VoidCallback onBack;

  const NutritionBuilderAppBar({
    super.key,
    required this.currentStep,
    required this.onBack,
  });

  static const _titles = [
    'Nutrition Plan Builder',
    'Choose Starting Point',
    'Build Nutrition Plan',
    'When to assign',
    'Review',
  ];

  static const _subtitles = [
    'Step 1: Select trainees',
    'Step 2: Template or custom',
    'Step 3: Add & customize meals',
    'Step 4: When to assign',
    'Step 5: Final check',
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
        ),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titles[currentStep - 1],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _subtitles[currentStep - 1],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
