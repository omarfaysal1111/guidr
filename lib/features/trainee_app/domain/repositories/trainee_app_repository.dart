import '../entities/trainee_app_profile.dart';
import '../entities/trainee_dashboard_today.dart';
import '../entities/complete_workout_request.dart';
import '../entities/trainee_exercise_plan_detail.dart';
import '../entities/nutrition_plan_detail.dart';
import '../entities/ingredient_library_item.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';

abstract class TraineeAppRepository {
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
  Future<void> completeMeal(int mealId);
  Future<void> skipMeal(int mealId);
  Future<void> skipIngredient(int mealId, int ingredientId);
  Future<void> swapIngredient(int mealId, int ingredientId, int newIngredientId);
  Future<List<IngredientLibraryItem>> searchIngredients(String query);
}
