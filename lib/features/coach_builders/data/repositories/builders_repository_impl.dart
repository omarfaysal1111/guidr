import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/plans.dart';
import '../../domain/entities/workout_plan_v1.dart';
import '../datasources/builders_remote_data_source.dart';



class BuildersRepositoryImpl implements BuildersRepository {
  final BuildersRemoteDataSource remoteDataSource;

  BuildersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Exercise>> getExercises() => remoteDataSource.getExercises();

  @override
  Future<List<Ingredient>> getIngredients() => remoteDataSource.getIngredients();

  @override
  Future<NutritionPlan> createNutritionPlan(Map<String, dynamic> payload) =>
      remoteDataSource.createNutritionPlan(payload);

  @override
  Future<List<NutritionPlan>> getMyNutritionPlans() => remoteDataSource.getMyNutritionPlans();

  @override
  Future<ExercisePlan> createExercisePlan(Map<String, dynamic> payload) =>
      remoteDataSource.createExercisePlan(payload);

  @override
  Future<List<ExercisePlan>> getMyExercisePlans() => remoteDataSource.getMyExercisePlans();

  @override
  Future<void> assignNutritionPlan({
    required int planId,
    required List<int> traineeIds,
  }) {
    return remoteDataSource.assignNutritionPlan(
      planId: planId,
      traineeIds: traineeIds,
    );
  }

  @override
  Future<void> assignExercisePlan({
    required int planId,
    required List<int> traineeIds,
  }) {
    return remoteDataSource.assignExercisePlan(
      planId: planId,
      traineeIds: traineeIds,
    );
  }

  @override
  Future<void> saveExercisePlanTemplate(Map<String, dynamic> payload) =>
      remoteDataSource.saveExercisePlanTemplate(payload);

  @override
  Future<void> saveExercisePlanDraft(Map<String, dynamic> payload) =>
      remoteDataSource.saveExercisePlanDraft(payload);

  @override
  Future<void> saveNutritionPlanTemplate(Map<String, dynamic> payload) =>
      remoteDataSource.saveNutritionPlanTemplate(payload);

  @override
  Future<void> saveNutritionPlanDraft(Map<String, dynamic> payload) =>
      remoteDataSource.saveNutritionPlanDraft(payload);

  @override
  Future<CreatedCoachWorkoutPlanV1> createWorkoutPlanV1({
    required String title,
    String? description,
    required int coachId,
  }) =>
      remoteDataSource.createWorkoutPlanV1(
        title: title,
        description: description,
        coachId: coachId,
      );

  @override
  Future<CreatedPlanSessionV1> createPlanSessionV1({
    required String planId,
    required String title,
    required int dayOrder,
  }) =>
      remoteDataSource.createPlanSessionV1(
        planId: planId,
        title: title,
        dayOrder: dayOrder,
      );

  @override
  Future<void> replacePlanSessionExercisesV1({
    required String planSessionId,
    required List<Map<String, dynamic>> lines,
  }) =>
      remoteDataSource.replacePlanSessionExercisesV1(
        planSessionId: planSessionId,
        lines: lines,
      );

  @override
  Future<void> assignWorkoutPlanV1({
    required String planId,
    required int traineeId,
    required String startDate,
  }) =>
      remoteDataSource.assignWorkoutPlanV1(
        planId: planId,
        traineeId: traineeId,
        startDate: startDate,
      );
}
