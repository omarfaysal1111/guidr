import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/entities/trainee_dashboard_today.dart';
import '../../domain/entities/complete_workout_request.dart';
import '../../domain/entities/trainee_exercise_plan_detail.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import '../../domain/repositories/trainee_app_repository.dart';
import '../datasources/trainee_app_remote_data_source.dart';

class TraineeAppRepositoryImpl implements TraineeAppRepository {
  final TraineeAppRemoteDataSource remoteDataSource;

  TraineeAppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TraineeAppProfile> getMyProfile() async {
    return await remoteDataSource.getMyProfile();
  }

  @override
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  }) async {
    return await remoteDataSource.updateMyProfile(
      fullName: fullName,
      fitnessGoal: fitnessGoal,
    );
  }

  @override
  Future<CoachProfile> getMyCoach() async {
    return await remoteDataSource.getMyCoach();
  }

  @override
  Future<List<NutritionPlan>> getMyNutritionPlans() async {
    return remoteDataSource.getMyNutritionPlans();
  }

  @override
  Future<List<ExercisePlan>> getMyExercisePlans() async {
    return remoteDataSource.getMyExercisePlans();
  }

  @override
  Future<TraineeDashboardToday> getDashboardToday() async {
    return remoteDataSource.getDashboardToday();
  }

  @override
  Future<TraineeExercisePlanDetail> getExercisePlanDetail(String planId) {
    return remoteDataSource.getExercisePlanDetail(planId);
  }

  @override
  Future<void> completePlanSessionWithLogs(
    String planSessionId,
    CompleteWorkoutRequest request,
  ) {
    return remoteDataSource.completePlanSessionWithLogs(
      planSessionId,
      request,
    );
  }

  @override
  Future<void> completeMeal(int mealId) {
    return remoteDataSource.completeMeal(mealId);
  }
}
