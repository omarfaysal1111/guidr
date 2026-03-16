import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/plans.dart';
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
}
