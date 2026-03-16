import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';
import '../../bloc/nutrition_builder_state.dart';

class NutritionBottomNavBar extends StatelessWidget {
  final VoidCallback onBackPressed;

  const NutritionBottomNavBar({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        if (state.currentStep == 2 || state.currentStep == 5) {
          return const SizedBox.shrink();
        }

        final bool canContinue = switch (state.currentStep) {
          1 => state.selectedTraineeIds.isNotEmpty,
          3 => state.planName.isNotEmpty,
          _ => true,
        };

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: canContinue
                  ? () => context
                      .read<NutritionBuilderBloc>()
                      .add(NutritionSetStep(state.currentStep + 1))
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _label(state),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  String _label(NutritionBuilderState s) => switch (s.currentStep) {
        1 =>
          'Continue with ${s.selectedTraineeIds.length} trainee${s.selectedTraineeIds.length == 1 ? '' : 's'} →',
        3 => 'Continue to Schedule →',
        4 => 'Review & Confirm →',
        _ => 'Continue →',
      };
}
