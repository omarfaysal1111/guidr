import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import 'package:guidr/features/coach_builders/domain/entities/workout_plan_v1.dart';

abstract class BuildersRepository {
  Future<List<Exercise>> getExercises();

  Future<List<Ingredient>> getIngredients();

  Future<NutritionPlan> createNutritionPlan(Map<String, dynamic> payload);

  Future<List<NutritionPlan>> getMyNutritionPlans();

  Future<ExercisePlan> createExercisePlan(Map<String, dynamic> payload);

  Future<List<ExercisePlan>> getMyExercisePlans();

  Future<void> assignNutritionPlan({
    required int planId,
    required List<int> traineeIds,
  });
  
  Future<void> assignExercisePlan({
    required int planId,
    required List<int> traineeIds,
  });

  Future<void> saveExercisePlanTemplate(Map<String, dynamic> payload);

  Future<void> saveExercisePlanDraft(Map<String, dynamic> payload);

  Future<void> saveNutritionPlanTemplate(Map<String, dynamic> payload);

  Future<void> saveNutritionPlanDraft(Map<String, dynamic> payload);

  Future<CreatedCoachWorkoutPlanV1> createWorkoutPlanV1({
    required String title,
    String? description,
    required int coachId,
  });

  Future<CreatedPlanSessionV1> createPlanSessionV1({
    required String planId,
    required String title,
    required int dayOrder,
  });

  Future<void> replacePlanSessionExercisesV1({
    required String planSessionId,
    required List<Map<String, dynamic>> lines,
  });

  Future<void> assignWorkoutPlanV1({
    required String planId,
    required int traineeId,
    required String startDate,
  });
}