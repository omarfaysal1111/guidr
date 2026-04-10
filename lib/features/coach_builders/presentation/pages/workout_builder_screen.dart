import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import '../bloc/workout_builder_bloc.dart';
import '../bloc/workout_builder_event.dart';
import '../bloc/workout_builder_state.dart';
import '../widgets/workout_app_bar.dart';
import '../widgets/workout_step_indicator.dart';
import '../widgets/workout_bottom_button.dart';
import '../widgets/steps/trainee_selection_step.dart';
import '../widgets/steps/template_starting_step.dart';
import '../widgets/steps/exercise_builder_step.dart';
import '../widgets/steps/schedule_step.dart';
import '../widgets/steps/review_confirm_step.dart';

class WorkoutBuilderPage extends StatelessWidget {
  final VoidCallback onBackPressed;

  const WorkoutBuilderPage({super.key, required this.onBackPressed});

  static Route<void> route({required VoidCallback onBackPressed}) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) =>
            di.sl<WorkoutBuilderBloc>()..add(WorkoutBuilderInit()),
        child: WorkoutBuilderPage(onBackPressed: onBackPressed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBuilderBloc, WorkoutBuilderState>(
      listener: (context, state) {
        if (state.assignSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan assigned successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          onBackPressed();
        }
        if (state.templateSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved as template!'),
              backgroundColor: Color(0xFF3B82F6),
            ),
          );
        }
        if (state.draftSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Draft saved!'),
              backgroundColor: Color(0xFF3B82F6),
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<WorkoutBuilderBloc>().add(const SetStep(5));
        }
      },
      listenWhen: (prev, curr) =>
          prev.assignSuccess != curr.assignSuccess ||
          prev.templateSaved != curr.templateSaved ||
          prev.draftSaved != curr.draftSaved ||
          prev.error != curr.error,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: WorkoutBuilderAppBar(
            currentStep: state.currentStep,
            onBack: () {
              if (state.currentStep > 1) {
                context
                    .read<WorkoutBuilderBloc>()
                    .add(SetStep(state.currentStep - 1));
              } else {
                onBackPressed();
              }
            },
          ),
          body: Column(
            children: [
              WorkoutStepIndicator(currentStep: state.currentStep),
              Expanded(child: _stepContent(state.currentStep)),
              WorkoutBottomNavBar(onBackPressed: onBackPressed),
            ],
          ),
        );
      },
    );
  }

  Widget _stepContent(int step) => switch (step) {
        1 => const TraineeSelectionStep(),
        2 => const TemplateStartingStep(),
        3 => const ExerciseBuilderStep(),
        4 => const ScheduleStep(),
        5 => const ReviewConfirmStep(),
        _ => const SizedBox.shrink(),
      };
}
