import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/entities/trainee_dashboard_today.dart';
import '../../domain/entities/trainee_exercise_plan_detail.dart';
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
  Future<List<ExercisePlan>> getMyExercisePlans();
  Future<TraineeDashboardToday> getDashboardToday();
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(int planId);
  Future<void> completeWorkout(int workoutId);
  Future<void> completeMeal(int mealId);
}
