import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/presentation/bloc/workout_builder_bloc.dart';
import 'package:guidr/features/coach_builders/presentation/bloc/workout_builder_event.dart';
import 'package:guidr/features/coach_builders/presentation/bloc/workout_builder_state.dart';

class WorkoutBottomNavBar extends StatelessWidget {
  final VoidCallback onBackPressed;

  const WorkoutBottomNavBar({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBuilderBloc, WorkoutBuilderState>(
      builder: (context, state) {
        if (state.currentStep == 2 || state.currentStep == 5) {
          return const SizedBox.shrink();
        }

        final bool canContinue = switch (state.currentStep) {
          1 => state.selectedTraineeIds.isNotEmpty,
          3 => state.workoutName.isNotEmpty,
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
                      .read<WorkoutBuilderBloc>()
                      .add(SetStep(state.currentStep + 1))
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _buttonLabel(state),
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

  String _buttonLabel(WorkoutBuilderState state) => switch (state.currentStep) {
        1 => 'Continue with ${state.selectedTraineeIds.length} trainees →',
        3 => 'Continue to Schedule →',
        4 => 'Review & Confirm →',
        _ => 'Continue →',
      };
}
