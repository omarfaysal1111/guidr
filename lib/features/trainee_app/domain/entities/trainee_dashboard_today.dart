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
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TraineeStreak(
      currentDays: _toInt(json['currentDays']),
      nextBadgeInDays: _toInt(json['nextBadgeInDays']),
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
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TodayWorkoutSummary(
      planId: json['planId']?.toString() ?? '',
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? '',
      exercisesTotal: _toInt(json['exercisesTotal']),
      exercisesDone: _toInt(json['exercisesDone']),
      durationMinutes: _toInt(json['durationMinutes']),
      estimatedCalories: _toInt(json['estimatedCalories']),
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
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TodayNutritionSummary(
      planId: _toInt(json['planId']),
      title: json['title'] ?? '',
      caloriesConsumed: _toInt(json['caloriesConsumed']),
      caloriesTarget: _toInt(json['caloriesTarget']),
      proteinGrams: _toInt(json['proteinGrams']),
      proteinTarget: _toInt(json['proteinTarget']),
      carbsGrams: _toInt(json['carbsGrams']),
      carbsTarget: _toInt(json['carbsTarget']),
      fatGrams: _toInt(json['fatGrams']),
      fatTarget: _toInt(json['fatTarget']),
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
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    return DashboardMeal(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      calories: _toInt(json['calories']),
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
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
    double _toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return WeeklyGoals(
      workoutsCompleted: _toInt(json['workoutsCompleted']),
      workoutsTarget: _toInt(json['workoutsTarget']),
      mealsLogged: _toInt(json['mealsLogged']),
      mealsTarget: _toInt(json['mealsTarget']),
      waterLiters: _toInt(json['waterLiters']),
      waterTargetLiters: _toInt(json['waterTargetLiters']),
      weightStart: _toDouble(json['weightStart']),
      weightCurrent: _toDouble(json['weightCurrent']),
      weightTarget: _toDouble(json['weightTarget']),
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

