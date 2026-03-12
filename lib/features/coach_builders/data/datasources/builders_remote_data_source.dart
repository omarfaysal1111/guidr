import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/plans.dart';

abstract class BuildersRemoteDataSource {
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
}

class BuildersRemoteDataSourceImpl implements BuildersRemoteDataSource {
  final ApiClient apiClient;

  BuildersRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Exercise>> getExercises() async {
    final response = await apiClient.get('/exercises');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => Exercise.fromJson(e)).toList();
  }

  @override
  Future<List<Ingredient>> getIngredients() async {
    final response = await apiClient.get('/ingredients');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => Ingredient.fromJson(e)).toList();
  }

  @override
  Future<NutritionPlan> createNutritionPlan(Map<String, dynamic> payload) async {
    final response = await apiClient.post('/coaches/nutrition-plans', body: payload);
    final data = response['data'] ?? response;
    return NutritionPlan.fromJson(data);
  }

  @override
  Future<List<NutritionPlan>> getMyNutritionPlans() async {
    final response = await apiClient.get('/coaches/nutrition-plans');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => NutritionPlan.fromJson(e)).toList();
  }

  @override
  Future<ExercisePlan> createExercisePlan(Map<String, dynamic> payload) async {
    final response = await apiClient.post('/coaches/exercise-plans', body: payload);
    final data = response['data'] ?? response;
    return ExercisePlan.fromJson(data);
  }

  @override
  Future<List<ExercisePlan>> getMyExercisePlans() async {
    final response = await apiClient.get('/coaches/exercise-plans');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => ExercisePlan.fromJson(e)).toList();
  }

  @override
  Future<void> assignNutritionPlan({
    required int planId,
    required List<int> traineeIds,
  }) async {
    await apiClient.post(
      '/coaches/nutrition-plans/$planId/assign',
      body: {
        'traineeIds': traineeIds,
      },
    );
  }

  @override
  Future<void> assignExercisePlan({
    required int planId,
    required List<int> traineeIds,
  }) async {
    await apiClient.post(
      '/coaches/exercise-plans/$planId/assign',
      body: {
        'traineeIds': traineeIds,
      },
    );
  }
}
