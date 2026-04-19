import '../entities/trainee_app_profile.dart';
import '../entities/trainee_dashboard_today.dart';
import '../entities/complete_workout_request.dart';
import '../entities/meal_completion_request.dart';
import '../entities/trainee_exercise_plan_detail.dart';
import '../entities/nutrition_plan_detail.dart';
import '../entities/ingredient_library_item.dart';
import '../entities/extra_meal_log.dart';
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
}
