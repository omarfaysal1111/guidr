import 'package:equatable/equatable.dart';

class TraineeDashboardToday extends Equatable {
  final TraineeDashboardProfile profile;
  final TraineeDashboardCoach coach;
  final TraineeStreak streak;
  final List<TraineeCoachGoal> coachGoals;
  final TodayWorkoutSummary todayWorkoutSummary;
  final TodayNutritionSummary todayNutritionSummary;
  final WeeklyGoals weeklyGoals;
  final List<TraineeAchievement> achievements;

  const TraineeDashboardToday({
    required this.profile,
    required this.coach,
    required this.streak,
    required this.coachGoals,
    required this.todayWorkoutSummary,
    required this.todayNutritionSummary,
    required this.weeklyGoals,
    required this.achievements,
  });

  factory TraineeDashboardToday.fromJson(Map<String, dynamic> json) {
    return TraineeDashboardToday(
      profile:
          TraineeDashboardProfile.fromJson(json['profile'] as Map<String, dynamic>),
      coach: TraineeDashboardCoach.fromJson(json['coach'] as Map<String, dynamic>),
      streak: TraineeStreak.fromJson(json['streak'] as Map<String, dynamic>),
      coachGoals: (json['coachGoals'] as List? ?? [])
          .map((e) => TraineeCoachGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayWorkoutSummary: TodayWorkoutSummary.fromJson(
        (json['todayWorkoutSummary'] as Map<String, dynamic>? ??
            <String, dynamic>{}),
      ),
      todayNutritionSummary: TodayNutritionSummary.fromJson(
        (json['todayNutritionSummary'] as Map<String, dynamic>? ??
            <String, dynamic>{}),
      ),
      weeklyGoals: WeeklyGoals.fromJson(
        (json['weeklyGoals'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      achievements: (json['achievements'] as List? ?? [])
          .map((e) => TraineeAchievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        profile,
        coach,
        streak,
        coachGoals,
        todayWorkoutSummary,
        todayNutritionSummary,
        weeklyGoals,
        achievements,
      ];
}

class TraineeDashboardProfile extends Equatable {
  final String id;
  final String fullName;
  final String? fitnessGoal;
  final String? avatarUrl;

  const TraineeDashboardProfile({
    required this.id,
    required this.fullName,
    this.fitnessGoal,
    this.avatarUrl,
  });

  factory TraineeDashboardProfile.fromJson(Map<String, dynamic> json) {
    return TraineeDashboardProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      fitnessGoal: json['fitnessGoal'],
      avatarUrl: json['avatarUrl'],
    );
  }

  @override
  List<Object?> get props => [id, fullName, fitnessGoal, avatarUrl];
}

class TraineeDashboardCoach extends Equatable {
  final int id;
  final String fullName;

  const TraineeDashboardCoach({
    required this.id,
    required this.fullName,
  });

  factory TraineeDashboardCoach.fromJson(Map<String, dynamic> json) {
    return TraineeDashboardCoach(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, fullName];
}

class TraineeStreak extends Equatable {
  final int currentDays;
  final int nextBadgeInDays;
  final String nextBadgeName;

  const TraineeStreak({
    required this.currentDays,
    required this.nextBadgeInDays,
    required this.nextBadgeName,
  });

  factory TraineeStreak.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TraineeStreak(
      currentDays: toInt(json['currentDays']),
      nextBadgeInDays: toInt(json['nextBadgeInDays']),
      nextBadgeName: json['nextBadgeName'] ?? '',
    );
  }

  @override
  List<Object?> get props => [currentDays, nextBadgeInDays, nextBadgeName];
}

class TraineeCoachGoal extends Equatable {
  final int id;
  final String label;
  final bool completed;

  const TraineeCoachGoal({
    required this.id,
    required this.label,
    required this.completed,
  });

  factory TraineeCoachGoal.fromJson(Map<String, dynamic> json) {
    return TraineeCoachGoal(
      id: json['id'] as int? ?? 0,
      label: json['label'] ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, label, completed];
}

class TodayWorkoutSummary extends Equatable {
  final String planId;
  final String title;
  final String difficulty;
  final int exercisesTotal;
  final int exercisesDone;
  final int durationMinutes;
  final int estimatedCalories;

  const TodayWorkoutSummary({
    required this.planId,
    required this.title,
    required this.difficulty,
    required this.exercisesTotal,
    required this.exercisesDone,
    required this.durationMinutes,
    required this.estimatedCalories,
  });

  factory TodayWorkoutSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TodayWorkoutSummary(
      planId: json['planId']?.toString() ?? '',
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? '',
      exercisesTotal: toInt(json['exercisesTotal']),
      exercisesDone: toInt(json['exercisesDone']),
      durationMinutes: toInt(json['durationMinutes']),
      estimatedCalories: toInt(json['estimatedCalories']),
    );
  }

  @override
  List<Object?> get props => [
        planId,
        title,
        difficulty,
        exercisesTotal,
        exercisesDone,
        durationMinutes,
        estimatedCalories,
      ];
}

class TodayNutritionSummary extends Equatable {
  final int planId;
  final String title;
  final int caloriesConsumed;
  final int caloriesTarget;
  final int proteinGrams;
  final int proteinTarget;
  final int carbsGrams;
  final int carbsTarget;
  final int fatGrams;
  final int fatTarget;
  final List<DashboardMeal> meals;

  const TodayNutritionSummary({
    required this.planId,
    required this.title,
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinGrams,
    required this.proteinTarget,
    required this.carbsGrams,
    required this.carbsTarget,
    required this.fatGrams,
    required this.fatTarget,
    required this.meals,
  });

  factory TodayNutritionSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TodayNutritionSummary(
      planId: toInt(json['planId']),
      title: json['title'] ?? '',
      caloriesConsumed: toInt(json['caloriesConsumed']),
      caloriesTarget: toInt(json['caloriesTarget']),
      proteinGrams: toInt(json['proteinGrams']),
      proteinTarget: toInt(json['proteinTarget']),
      carbsGrams: toInt(json['carbsGrams']),
      carbsTarget: toInt(json['carbsTarget']),
      fatGrams: toInt(json['fatGrams']),
      fatTarget: toInt(json['fatTarget']),
      meals: (json['meals'] as List? ?? [])
          .map((e) => DashboardMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        planId,
        title,
        caloriesConsumed,
        caloriesTarget,
        proteinGrams,
        proteinTarget,
        carbsGrams,
        carbsTarget,
        fatGrams,
        fatTarget,
        meals,
      ];
}

class DashboardMeal extends Equatable {
  final int id;
  final String name;
  final int calories;
  final bool completed;

  const DashboardMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.completed,
  });

  factory DashboardMeal.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    return DashboardMeal(
      id: toInt(json['id']),
      name: json['name'] ?? '',
      calories: toInt(json['calories']),
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, calories, completed];
}

class WeeklyGoals extends Equatable {
  final int workoutsCompleted;
  final int workoutsTarget;
  final int mealsLogged;
  final int mealsTarget;
  final int waterLiters;
  final int waterTargetLiters;
  final double weightStart;
  final double weightCurrent;
  final double weightTarget;

  const WeeklyGoals({
    required this.workoutsCompleted,
    required this.workoutsTarget,
    required this.mealsLogged,
    required this.mealsTarget,
    required this.waterLiters,
    required this.waterTargetLiters,
    required this.weightStart,
    required this.weightCurrent,
    required this.weightTarget,
  });

  factory WeeklyGoals.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return WeeklyGoals(
      workoutsCompleted: toInt(json['workoutsCompleted']),
      workoutsTarget: toInt(json['workoutsTarget']),
      mealsLogged: toInt(json['mealsLogged']),
      mealsTarget: toInt(json['mealsTarget']),
      waterLiters: toInt(json['waterLiters']),
      waterTargetLiters: toInt(json['waterTargetLiters']),
      weightStart: toDouble(json['weightStart']),
      weightCurrent: toDouble(json['weightCurrent']),
      weightTarget: toDouble(json['weightTarget']),
    );
  }

  @override
  List<Object?> get props => [
        workoutsCompleted,
        workoutsTarget,
        mealsLogged,
        mealsTarget,
        waterLiters,
        waterTargetLiters,
        weightStart,
        weightCurrent,
        weightTarget,
      ];
}

class TraineeAchievement extends Equatable {
  final String code;
  final String label;
  final String level;
  final bool unlocked;

  const TraineeAchievement({
    required this.code,
    required this.label,
    required this.level,
    required this.unlocked,
  });

  factory TraineeAchievement.fromJson(Map<String, dynamic> json) {
    return TraineeAchievement(
      code: json['code'] ?? '',
      label: json['label'] ?? '',
      level: json['level'] ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [code, label, level, unlocked];
}

