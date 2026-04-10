import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/plans.dart';
import '../../domain/entities/workout_plan_v1.dart';

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
    debugPrint('createExercisePlan payload: ${jsonEncode(payload)}');
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
        'traineeIds': traineeIds
      },
    );
  }

  @override
  Future<void> saveExercisePlanTemplate(Map<String, dynamic> payload) async {
    await apiClient.post('/coaches/exercise-plans/templates', body: payload);
  }

  @override
  Future<void> saveExercisePlanDraft(Map<String, dynamic> payload) async {
    await apiClient.post('/coaches/exercise-plans/drafts', body: payload);
  }

  @override
  Future<void> saveNutritionPlanTemplate(Map<String, dynamic> payload) async {
    await apiClient.post('/coaches/nutrition-plans/templates', body: payload);
  }

  @override
  Future<void> saveNutritionPlanDraft(Map<String, dynamic> payload) async {
    await apiClient.post('/coaches/nutrition-plans/drafts', body: payload);
  }

  @override
  Future<CreatedCoachWorkoutPlanV1> createWorkoutPlanV1({
    required String title,
    String? description,
    required int coachId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'coachId': coachId,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    final response = await apiClient.post('/v1/plans', body: body);
    final data = (response['data'] as Map<String, dynamic>?) ?? response;
    return CreatedCoachWorkoutPlanV1.fromJson(data);
  }

  @override
  Future<CreatedPlanSessionV1> createPlanSessionV1({
    required String planId,
    required String title,
    required int dayOrder,
  }) async {
    final response = await apiClient.post(
      '/v1/plans/$planId/workouts',
      body: {
        'title': title,
        'dayOrder': dayOrder,
      },
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? response;
    return CreatedPlanSessionV1.fromJson(data);
  }

  @override
  Future<void> replacePlanSessionExercisesV1({
    required String planSessionId,
    required List<Map<String, dynamic>> lines,
  }) async {
    await apiClient.postJson(
      '/v1/workouts/$planSessionId/exercises',
      body: lines,
    );
  }

  @override
  Future<void> assignWorkoutPlanV1({
    required String planId,
    required int traineeId,
    required String startDate,
  }) async {
    await apiClient.post(
      '/v1/plans/$planId/assign',
      body: {
        'traineeId': traineeId,
        'startDate': startDate,
      },
    );
  }
}
