import 'package:guidr/core/network/api_client.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/entities/trainee_dashboard_today.dart';
import '../../domain/entities/complete_workout_request.dart';
import '../../domain/entities/trainee_exercise_plan_detail.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';

abstract class TraineeAppRemoteDataSource {
  Future<TraineeAppProfile> getMyProfile();
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  });
  Future<CoachProfile> getMyCoach();
  Future<List<NutritionPlan>> getMyNutritionPlans();
  Future<List<ExercisePlan>> getMyExercisePlans();
  Future<TraineeDashboardToday> getDashboardToday();
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(String planId);
  Future<void> completePlanSessionWithLogs(
    String planSessionId,
    CompleteWorkoutRequest request,
  );
  Future<void> completeMeal(int mealId);
}

class TraineeAppRemoteDataSourceImpl implements TraineeAppRemoteDataSource {
  final ApiClient apiClient;

  TraineeAppRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TraineeAppProfile> getMyProfile() async {
    final response = await apiClient.get('/trainees/me');
    final data = response['data'] ?? response;
    return TraineeAppProfile.fromJson(data);
  }

  @override
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (fitnessGoal != null) body['fitnessGoal'] = fitnessGoal;

    final response = await apiClient.put(
      '/trainees/me',
      body: body,
    );
    final data = response['data'] ?? response;
    return TraineeAppProfile.fromJson(data);
  }

  @override
  Future<CoachProfile> getMyCoach() async {
    final response = await apiClient.get('/trainees/coach');
    final data = response['data'] ?? response;
    return CoachProfile.fromJson(data);
  }

  @override
  Future<List<NutritionPlan>> getMyNutritionPlans() async {
    final response = await apiClient.get('/trainees/me/nutrition-plans');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => NutritionPlan.fromJson(e)).toList();
  }

  @override
  Future<List<ExercisePlan>> getMyExercisePlans() async {
    final response = await apiClient.get('/trainees/me/exercise-plans');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => ExercisePlan.fromJson(e)).toList();
  }

  @override
  Future<TraineeDashboardToday> getDashboardToday() async {
    final response = await apiClient.get('/trainees/me/dashboard-today');
    final data = (response['data'] as Map<String, dynamic>?) ?? response;
    return TraineeDashboardToday.fromJson(data);
  }

  @override
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(String planId) async {
    final response =
        await apiClient.get('/trainees/me/exercise-plans/$planId');
    final data = (response['data'] as Map<String, dynamic>?) ?? response;
    return TraineeExercisePlanDetail.fromJson(data);
  }

  @override
  Future<void> completePlanSessionWithLogs(
    String planSessionId,
    CompleteWorkoutRequest request,
  ) async {
    await apiClient.post(
      '/trainees/me/plan-sessions/$planSessionId/complete-with-logs',
      body: request.toJson(),
    );
  }

  @override
  Future<void> completeMeal(int mealId) async {
    await apiClient.post(
      '/trainees/me/meals/$mealId/complete',
      body: <String, dynamic>{},
    );
  }
}
