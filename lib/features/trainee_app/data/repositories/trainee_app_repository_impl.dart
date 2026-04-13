import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/entities/trainee_dashboard_today.dart';
import '../../domain/entities/complete_workout_request.dart';
import '../../domain/entities/trainee_exercise_plan_detail.dart';
import '../../domain/entities/nutrition_plan_detail.dart';
import '../../domain/entities/ingredient_library_item.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import '../../domain/repositories/trainee_app_repository.dart';
import '../datasources/trainee_app_remote_data_source.dart';

class TraineeAppRepositoryImpl implements TraineeAppRepository {
  final TraineeAppRemoteDataSource remoteDataSource;

  TraineeAppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TraineeAppProfile> getMyProfile() =>
      remoteDataSource.getMyProfile();

  @override
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  }) =>
      remoteDataSource.updateMyProfile(
        fullName: fullName,
        fitnessGoal: fitnessGoal,
      );

  @override
  Future<CoachProfile> getMyCoach() => remoteDataSource.getMyCoach();

  @override
  Future<List<NutritionPlan>> getMyNutritionPlans() =>
      remoteDataSource.getMyNutritionPlans();

  @override
  Future<List<NutritionPlanDetail>> getMyNutritionPlanDetails() =>
      remoteDataSource.getMyNutritionPlanDetails();

  @override
  Future<List<ExercisePlan>> getMyExercisePlans() =>
      remoteDataSource.getMyExercisePlans();

  @override
  Future<TraineeDashboardToday> getDashboardToday() =>
      remoteDataSource.getDashboardToday();

  @override
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(String planId) =>
      remoteDataSource.getExercisePlanDetail(planId);

  @override
  Future<void> completePlanSessionWithLogs(
    String planSessionId,
    CompleteWorkoutRequest request,
  ) =>
      remoteDataSource.completePlanSessionWithLogs(planSessionId, request);

  @override
  Future<void> completeMeal(int mealId) =>
      remoteDataSource.completeMeal(mealId);

  @override
  Future<void> skipMeal(int mealId) => remoteDataSource.skipMeal(mealId);

  @override
  Future<void> skipIngredient(int mealId, int ingredientId) =>
      remoteDataSource.skipIngredient(mealId, ingredientId);

  @override
  Future<void> swapIngredient(
          int mealId, int ingredientId, int newIngredientId) =>
      remoteDataSource.swapIngredient(mealId, ingredientId, newIngredientId);

  @override
  Future<List<IngredientLibraryItem>> searchIngredients(String query) =>
      remoteDataSource.searchIngredients(query);
}
