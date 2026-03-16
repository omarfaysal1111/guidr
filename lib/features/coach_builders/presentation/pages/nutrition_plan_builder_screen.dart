import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import '../bloc/nutrition_builder_bloc.dart';
import '../bloc/nutrition_builder_event.dart';
import '../bloc/nutrition_builder_state.dart';
import '../widgets/nutrition/nutrition_app_bar.dart';
import '../widgets/nutrition/nutrition_step_indicator.dart';
import '../widgets/nutrition/nutrition_bottom_button.dart';
import '../widgets/nutrition/nutrition_trainee_step.dart';
import '../widgets/nutrition/nutrition_template_step.dart';
import '../widgets/nutrition/nutrition_meals_step.dart';
import '../widgets/nutrition/nutrition_schedule_step.dart';
import '../widgets/nutrition/nutrition_review_step.dart';

class NutritionPlanBuilderScreen extends StatelessWidget {
  final VoidCallback onBackPressed;

  const NutritionPlanBuilderScreen({super.key, required this.onBackPressed});

  static Route<void> route({required VoidCallback onBackPressed}) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) =>
            di.sl<NutritionBuilderBloc>()..add(NutritionBuilderInit()),
        child: NutritionPlanBuilderScreen(onBackPressed: onBackPressed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NutritionBuilderBloc, NutritionBuilderState>(
      listener: (context, state) {
        if (state.assignSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nutrition plan assigned successfully!'),
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
          appBar: NutritionBuilderAppBar(
            currentStep: state.currentStep,
            onBack: () {
              if (state.currentStep > 1) {
                context
                    .read<NutritionBuilderBloc>()
                    .add(NutritionSetStep(state.currentStep - 1));
              } else {
                onBackPressed();
              }
            },
          ),
          body: Column(
            children: [
              NutritionStepIndicator(currentStep: state.currentStep),
              Expanded(child: _stepContent(state.currentStep)),
              NutritionBottomNavBar(onBackPressed: onBackPressed),
            ],
          ),
        );
      },
    );
  }

  Widget _stepContent(int step) => switch (step) {
        1 => const NutritionTraineeStep(),
        2 => const NutritionTemplateStep(),
        3 => const NutritionMealsStep(),
        4 => const NutritionScheduleStep(),
        5 => const NutritionReviewStep(),
        _ => const SizedBox.shrink(),
      };
}
