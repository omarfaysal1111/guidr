import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';

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
}