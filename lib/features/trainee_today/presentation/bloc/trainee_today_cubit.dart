import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import 'package:guidr/features/coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_app_profile.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';

class TraineeTodayState extends Equatable {
  final bool loading;
  final String? error;
  final TraineeAppProfile? profile;
  final CoachProfile? coach;
  final List<ExercisePlan> exercisePlans;
  final List<NutritionPlan> nutritionPlans;
  final TraineeDashboardToday? dashboard;

  const TraineeTodayState({
    required this.loading,
    required this.exercisePlans,
    required this.nutritionPlans,
    this.error,
    this.profile,
    this.coach,
    this.dashboard,
  });

  factory TraineeTodayState.initial() => const TraineeTodayState(
        loading: true,
        exercisePlans: [],
        nutritionPlans: [],
      );

  TraineeTodayState copyWith({
    bool? loading,
    String? error,
    TraineeAppProfile? profile,
    CoachProfile? coach,
    List<ExercisePlan>? exercisePlans,
    List<NutritionPlan>? nutritionPlans,
    TraineeDashboardToday? dashboard,
    bool clearError = false,
  }) {
    return TraineeTodayState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      profile: profile ?? this.profile,
      coach: coach ?? this.coach,
      exercisePlans: exercisePlans ?? this.exercisePlans,
      nutritionPlans: nutritionPlans ?? this.nutritionPlans,
      dashboard: dashboard ?? this.dashboard,
    );
  }

  @override
  List<Object?> get props =>
      [loading, error, profile, coach, exercisePlans, nutritionPlans, dashboard];
}

class TraineeTodayCubit extends Cubit<TraineeTodayState> {
  final TraineeAppRepository repository;

  TraineeTodayCubit({required this.repository})
      : super(TraineeTodayState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      // Profile is required; fail if this call fails.
      final profile = await repository.getMyProfile();

      CoachProfile? coach;
      List<ExercisePlan> exercisePlans = const [];
      List<NutritionPlan> nutritionPlans = const [];
      TraineeDashboardToday? dashboard;

      // Non-critical calls: if they fail (e.g. no coach, no dashboard yet),
      // we keep going with fallbacks instead of breaking the whole screen.
      try {
        coach = await repository.getMyCoach();
      } catch (_) {}

      try {
        exercisePlans = await repository.getMyExercisePlans();
      } catch (_) {}

      try {
        nutritionPlans = await repository.getMyNutritionPlans();
      } catch (_) {}

      try {
        dashboard = await repository.getDashboardToday();
      } catch (_) {}

      emit(
        state.copyWith(
          loading: false,
          profile: profile,
          coach: coach,
          exercisePlans: exercisePlans,
          nutritionPlans: nutritionPlans,
          dashboard: dashboard,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}

