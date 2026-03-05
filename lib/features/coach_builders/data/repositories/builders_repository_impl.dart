import '../../domain/entities/exercise.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/plans.dart';
import '../datasources/builders_remote_data_source.dart';

abstract class BuildersRepository {
  Future<List<Exercise>> getExercises();
  Future<List<Ingredient>> getIngredients();
  Future<NutritionPlan> createNutritionPlan(Map<String, dynamic> payload);
  Future<List<NutritionPlan>> getMyNutritionPlans();
  Future<ExercisePlan> createExercisePlan(Map<String, dynamic> payload);
  Future<List<ExercisePlan>> getMyExercisePlans();
}

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
}
