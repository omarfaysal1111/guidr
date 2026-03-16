import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';

class WorkoutStepIndicator extends StatelessWidget {
  final int currentStep;

  const WorkoutStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Trainees', 'Template', 'Exercises', 'Schedule', 'Review'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final stepNum = index + 1;
          final isCompleted = currentStep > stepNum;
          final isActive = currentStep == stepNum;

          return Expanded(
            child: Row(
              children: [
                // The Step Circle
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive ? AppColors.primary : AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isActive || isCompleted ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                // The Connecting Line (hidden for the last step)
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
                      color: currentStep > stepNum ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}