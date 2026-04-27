import 'package:guidr/core/network/api_client.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/entities/trainee_dashboard_today.dart';
import '../../domain/entities/complete_workout_request.dart';
import '../../domain/entities/meal_completion_request.dart';
import '../../domain/entities/trainee_exercise_plan_detail.dart';
import '../../domain/entities/nutrition_plan_detail.dart';
import '../../domain/entities/ingredient_library_item.dart';
import '../../domain/entities/extra_meal_log.dart';
import '../../domain/entities/water_intake_day.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';

abstract class TraineeAppRemoteDataSource {
  Future<TraineeAppProfile> getMyProfile();
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  });
  Future<CoachProfile> getMyCoach();
  Future<List<NutritionPlan>> getMyNutritionPlans();
  Future<List<NutritionPlanDetail>> getMyNutritionPlanDetails();
  Future<List<ExercisePlan>> getMyExercisePlans();
  Future<TraineeDashboardToday> getDashboardToday();
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(String planId);
  Future<void> completePlanSessionWithLogs(
    String planSessionId,
    CompleteWorkoutRequest request,
  );
  Future<void> completeMeal(int mealId, MealCompletionRequest request);
  Future<List<IngredientLibraryItem>> searchIngredients(String query);
  Future<List<IngredientLibraryItem>> getIngredientsCatalog();
  Future<ExtraMealLog> logExtraMeal({
    int? ingredientId,
    String? name,
    required double calories,
    required String dateIso,
  });
  Future<void> uploadProgressPhoto(List<int> fileBytes, String fileName);
  Future<void> uploadInBodyReport(List<int> fileBytes, String fileName);
  /// [date] optional — defaults to today on the server.
  Future<WaterIntakeDay> getMyWaterIntake({DateTime? date});
  /// Replaces the total liters logged for that calendar day.
  Future<WaterIntakeDay> setMyWaterIntake({
    required double liters,
    required String dateIso,
  });
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

    final response = await apiClient.put('/trainees/me', body: body);
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
  Future<List<NutritionPlanDetail>> getMyNutritionPlanDetails() async {
    final response = await apiClient.get('/trainees/me/nutrition-plans');
    final data = response['data'] as List? ?? response as List;
    return data
        .map((e) => NutritionPlanDetail.fromJson(e as Map<String, dynamic>))
        .toList();
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
  Future<void> completeMeal(int mealId, MealCompletionRequest request) async {
    await apiClient.post(
      '/trainees/me/meals/$mealId/complete',
      body: request.toJson(),
    );
  }

  @override
  Future<List<IngredientLibraryItem>> searchIngredients(String query) async {
    final response =
        await apiClient.get('/ingredients?search=${Uri.encodeComponent(query)}');
    final raw = response['data'] as List? ?? response as List? ?? [];
    return raw
        .map((e) =>
            IngredientLibraryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IngredientLibraryItem>> getIngredientsCatalog() async {
    final response = await apiClient.get('/ingredients');
    final raw = response['data'] as List? ?? response as List? ?? [];
    return raw
        .map((e) =>
            IngredientLibraryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExtraMealLog> logExtraMeal({
    int? ingredientId,
    String? name,
    required double calories,
    required String dateIso,
  }) async {
    final body = <String, dynamic>{
      'calories': calories,
      'date': dateIso,
    };
    if (ingredientId != null) {
      body['ingredientId'] = ingredientId;
    }
    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }
    final response = await apiClient.post(
      '/trainees/me/extra-meals',
      body: body,
    );
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return ExtraMealLog.fromJson(data);
    }
    return ExtraMealLog(
      name: name ?? '',
      calories: calories,
      date: DateTime.tryParse(dateIso) ?? DateTime.now(),
      ingredientId: ingredientId,
    );
  }

  @override
  Future<void> uploadProgressPhoto(List<int> fileBytes, String fileName) async {
    await apiClient.postMultipart(
      '/trainees/me/progress-photos',
      file: http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
  }

  @override
  Future<void> uploadInBodyReport(List<int> fileBytes, String fileName) async {
    await apiClient.postMultipart(
      '/trainees/me/inbody-reports',
      file: http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
  }

  @override
  Future<WaterIntakeDay> getMyWaterIntake({DateTime? date}) async {
    final path = date == null
        ? '/trainees/me/water-intake'
        : '/trainees/me/water-intake?date=${Uri.encodeComponent(WaterIntakeDay.formatDate(date))}';
    final response = await apiClient.get(path);
    final raw = response['data'] ?? response;
    final m = Map<String, dynamic>.from(raw as Map);
    return WaterIntakeDay.fromJson(m);
  }

  @override
  Future<WaterIntakeDay> setMyWaterIntake({
    required double liters,
    required String dateIso,
  }) async {
    final response = await apiClient.put(
      '/trainees/me/water-intake',
      body: {
        'liters': liters,
        'date': dateIso,
      },
    );
    final raw = response['data'] ?? response;
    if (raw is! Map) {
      return getMyWaterIntake(date: DateTime.tryParse(dateIso));
    }
    return WaterIntakeDay.fromJson(Map<String, dynamic>.from(raw));
  }
}
