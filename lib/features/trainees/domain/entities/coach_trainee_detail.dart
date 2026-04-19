import 'package:equatable/equatable.dart';

import 'coach_trainee_plans_data.dart';
import 'coach_trainee_progress_extra.dart';
import 'coach_trainee_workout_completion_history.dart';
import 'coach_trainee_meal_completion_history.dart';
import 'coach_trainee_workout_sessions.dart';
import 'trainee.dart';
import 'trainee_health_history.dart';
import 'inbody_report.dart';
import 'progress_photo.dart';
import '../../../../features/trainee_progress/domain/entities/trainee_measurement.dart';
import '../../../../features/trainee_progress/domain/entities/trainee_progress_picture.dart';

/// `GET /coaches/trainees/:id`
///
/// **Plans tab (default):** reads from `profile`:
/// `workoutsCompletedToday`, `workoutsPlannedToday`, `workoutProgressPercent`,
/// `mealsCompletedToday`, `mealsPlannedToday`, `nutritionProgressPercent`, `adherencePercent`.
///
/// **Optional** rich payloads (root or `plansTab`): `workoutProgress` / `nutritionProgress` with
/// `weekDays` lists, and `workoutPlans`.
///
/// **Workout day exercise logs:** `workoutDaySessions` (or aliases in [CoachTraineeDetail.fromJson])
/// may include per-exercise `setDetails` or per-set `sets` / `setLogs` for coach UI (see
/// [CoachTraineeWorkoutExerciseLog] in `coach_trainee_workout_sessions.dart`).
///
/// **Plan row preview:** each `workoutPlans[]` item may include `sessionsPreview` with prescribed
/// sessions and exercises (see [CoachTraineeWorkoutPlanRow] in `coach_trainee_plans_data.dart`).
///
/// **Completion history:** `workoutCompletionHistory` lists past session completions with
/// `exerciseLogs` and `setDetails` (see [CoachTraineeWorkoutCompletionRecord]).
///
/// **Progress tab:** `traineeFeedback` / `feedback`, `goals`, `progressPhotos` / `progress_photos`
/// (see [ProgressPhoto]), `inbodyReports` / `inbody_reports` (see [InBodyReport]), and on `profile`:
/// `coachNotesToTrainee` / `coachNotes`, `cautionNotes` / `medicalNotes`.
///
/// **Health history sheet:** nested `profile.healthHistory` or same keys on `profile`
/// (`trainingExperience`, `previousTraining`, `reasonForStopping`, `diseasesOrConditions`,
/// `allergies`, `injuries`, `medications`, plus `goal` / `fitnessGoal`).
class CoachTraineeDetail extends Equatable {
  final Trainee profile;
  final List<TraineeMeasurement> recentMeasurements;
  final List<TraineeProgressPicture> recentPictures;
  final CoachTraineeWorkoutProgress workoutProgress;
  final CoachTraineeNutritionProgress nutritionProgress;
  final List<CoachTraineeWorkoutPlanRow> workoutPlans;
  final List<CoachTraineeFeedbackEntry> traineeFeedback;
  final List<CoachTraineeGoalItem> traineeGoals;
  final List<InBodyReport> inbodyReports;
  final List<ProgressPhoto> progressPhotos;
  final String? coachNotesToTrainee;
  final String? coachCautionNotes;
  final TraineeHealthHistory healthHistory;
  
  /// Optional per-day session breakdown (exercises, sets) from API.
  final List<CoachTraineeWorkoutDaySession> workoutDaySessions;
  final List<CoachTraineeSkippedSetRecord> recentSkippedSets;
  
  /// Trainee comment on the current plan (Plans tab callout).
  final String? traineeNoteOnPlan;
  
  /// Pre-formatted range, e.g. from API; otherwise UI may derive current week.
  final String? workoutWeekRangeLabel;
  
  /// Logged session completions with per-set detail (`workoutCompletionHistory` on API).
  final List<CoachTraineeWorkoutCompletionRecord> workoutCompletionHistory;
  
  /// Logged meal completions with ingredient deviations (`mealCompletionHistory` on API).
  final List<MealCompletionRecord> mealCompletionHistory;
  
  final int missedWorkoutCount;
  final int missedMealCount;

  const CoachTraineeDetail({
    required this.profile,
    required this.recentMeasurements,
    required this.recentPictures,
    required this.workoutProgress,
    required this.nutritionProgress,
    required this.workoutPlans,
    this.traineeFeedback = const [],
    this.traineeGoals = const [],
    this.inbodyReports = const [],
    this.progressPhotos = const [],
    this.coachNotesToTrainee,
    this.coachCautionNotes,
    required this.healthHistory,
    this.workoutDaySessions = const [],
    this.recentSkippedSets = const [],
    this.traineeNoteOnPlan,
    this.workoutWeekRangeLabel,
    this.workoutCompletionHistory = const [],
    this.mealCompletionHistory = const [],
    required this.missedWorkoutCount, 
    required this.missedMealCount,
  });

  // --- Helper Methods ---

  static String _calendarDayKey(DateTime day) {
    final y = day.year;
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String? _pickString(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static Map<String, dynamic> _plansSection(Map<String, dynamic> json) {
    final tab = json['plansTab'];
    if (tab is Map<String, dynamic>) return tab;
    return json;
  }

  static bool _hasWeekList(Map<String, dynamic>? j) {
    if (j == null || j.isEmpty) return false;
    final d = j['weekDays'] ?? j['days'] ?? j['daily'];
    return d is List && d.isNotEmpty;
  }

  // --- Core Methods ---

  /// Latest completion on [day] (local calendar date), or null.
  CoachTraineeWorkoutCompletionRecord? bestCompletionForCalendarDay(DateTime day) {
    final key = _calendarDayKey(DateTime(day.year, day.month, day.day));
    final matches = workoutCompletionHistory.where((c) => c.completionDate == key).toList();
    
    if (matches.isEmpty) return null;
    
    matches.sort((a, b) {
      final ta = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta); // Descending order
    });
    
    return matches.first;
  }

  /// Exercise rows from completion API for that calendar day (for Plans tab day card).
  List<CoachTraineeWorkoutExerciseLog> completionExercisesForCalendarDay(DateTime day) {
    final r = bestCompletionForCalendarDay(day);
    if (r == null || !r.hasDetailedLogs || r.exerciseLogs.isEmpty) {
      return [];
    }
    return r.exerciseLogs.map((e) => e.toWorkoutExerciseLog()).toList();
  }

  /// Week strip + API sessions + [recentSkippedSets] for selectable day details.
  List<CoachTraineeWorkoutDaySession> get mergedWorkoutWeek => buildMergedWorkoutWeek(
        wp: workoutProgress,
        apiSessions: workoutDaySessions,
        skippedSets: recentSkippedSets,
      );

  // --- Factory Constructor ---

  factory CoachTraineeDetail.fromJson(Map<String, dynamic> json) {
    final section = _plansSection(json);
    
    final profileRaw = json['profile'];
    final profileMap = profileRaw is Map<String, dynamic> ? profileRaw : <String, dynamic>{};

    final workoutJson = (section['workoutProgress'] ?? json['workoutProgress']) as Map<String, dynamic>?;
    final nutritionJson = (section['nutritionProgress'] ?? json['nutritionProgress']) as Map<String, dynamic>?;
    
    final plansList = section['workoutPlans'] ?? json['workoutPlans'];
    final plans = plansList is List
        ? plansList.whereType<Map<String, dynamic>>().map(CoachTraineeWorkoutPlanRow.fromJson).toList()
        : <CoachTraineeWorkoutPlanRow>[];

    final workoutProgress = _hasWeekList(workoutJson)
        ? CoachTraineeWorkoutProgress.fromJson(workoutJson!)
        : CoachTraineeWorkoutProgress.fromCoachProfileMap(profileMap);

    final nutritionProgress = _hasWeekList(nutritionJson)
        ? CoachTraineeNutritionProgress.fromJson(nutritionJson!)
        : CoachTraineeNutritionProgress.fromCoachProfileMap(profileMap);

    final feedbackRaw = json['traineeFeedback'] ??
        json['feedback'] ??
        profileMap['traineeFeedback'] ??
        profileMap['feedback'];
        
    final goalsRaw = json['goals'] ?? profileMap['goals'] ?? profileMap['traineeGoals'];

    final inbodyRaw = json['inbodyReports'] ??
        json['inbody_reports'] ??
        profileMap['inbodyReports'] ??
        profileMap['inbody_reports'];

    final progressPhotosRaw = json['progressPhotos'] ??
        json['progress_photos'] ??
        profileMap['progressPhotos'] ??
        profileMap['progress_photos'];

    final coachNotes = _pickString(profileMap, [
      'coachNotesToTrainee',
      'coachNotes',
      'coachFeedback',
      'feedbackForTrainee',
    ]);
    
    final caution = _pickString(profileMap, [
      'cautionNotes',
      'medicalNotes',
      'coachCautionNotes',
    ]);

    final historyRaw = json['workoutCompletionHistory'] ??
        section['workoutCompletionHistory'] ??
        profileMap['workoutCompletionHistory'];
    final completionHistory = parseWorkoutCompletionHistory(historyRaw);

    final mealHistoryRaw = json['mealCompletionHistory'] ??
        section['mealCompletionHistory'] ??
        profileMap['mealCompletionHistory'];
    final mealHistory = parseMealCompletionHistory(mealHistoryRaw);

    final sessionsRaw = section['workoutDaySessions'] ??
        json['workoutDaySessions'] ??
        workoutJson?['daySessions'] ??
        workoutJson?['sessions'] ??
        profileMap['workoutDaySessions'] ??
        profileMap['workoutSessions'];
        
    final skippedRaw = json['recentSkippedSets'] ??
        section['recentSkippedSets'] ??
        profileMap['recentSkippedSets'];
        
    final planNote = _pickString(profileMap, [
      'traineeNoteOnPlan',
      'traineePlanNote',
      'workoutPlanNote',
      'planNoteFromTrainee',
    ]);
    
    const weekRangeKeys = [
      'workoutWeekRange',
      'workoutWeekRangeLabel',
      'weekRangeLabel',
      'weekRange',
    ];
    
    String? weekRange = _pickString(profileMap, weekRangeKeys) ??
        _pickString(workoutJson, weekRangeKeys) ??
        _pickString(section, weekRangeKeys) ??
        _pickString(json, weekRangeKeys);
        
    if (weekRange == null) {
      final ws = workoutJson?['weekStart'] ?? profileMap['workoutWeekStart'];
      final we = workoutJson?['weekEnd'] ?? profileMap['workoutWeekEnd'];
      if (ws is String && we is String && ws.trim().isNotEmpty && we.trim().isNotEmpty) {
        weekRange = '${ws.trim()} to ${we.trim()}';
      }
    }

    final profile = Trainee.fromJson(profileMap);

    return CoachTraineeDetail(
      profile: profile,
      recentMeasurements: (json['recentMeasurements'] as List? ?? [])
          .map((e) => TraineeMeasurement.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentPictures: (json['recentPictures'] as List? ?? [])
          .map((e) => TraineeProgressPicture.fromJson(e as Map<String, dynamic>))
          .toList(),
      workoutProgress: workoutProgress,
      nutritionProgress: nutritionProgress,
      workoutPlans: plans,
      traineeFeedback: parseFeedbackList(feedbackRaw),
      traineeGoals: parseGoalsList(goalsRaw),
      inbodyReports: parseInBodyReportsList(inbodyRaw),
      progressPhotos: parseProgressPhotosList(progressPhotosRaw),
      coachNotesToTrainee: coachNotes,
      coachCautionNotes: caution,
      healthHistory: TraineeHealthHistory.fromProfileMap(profileMap, profile),
      workoutDaySessions: parseWorkoutDaySessionsList(sessionsRaw),
      recentSkippedSets: parseSkippedSetsList(skippedRaw),
      traineeNoteOnPlan: planNote,
      workoutWeekRangeLabel: weekRange,
      workoutCompletionHistory: completionHistory,
      mealCompletionHistory: mealHistory,
      missedMealCount: (json['missedMealCount'] as num?)?.toInt() ?? 0,
      missedWorkoutCount: (json['missedWorkoutCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        recentMeasurements,
        recentPictures,
        workoutProgress,
        nutritionProgress,
        workoutPlans,
        traineeFeedback,
        traineeGoals,
        inbodyReports,
        progressPhotos,
        coachNotesToTrainee,
        coachCautionNotes,
        healthHistory,
        workoutDaySessions,
        recentSkippedSets,
        traineeNoteOnPlan,
        workoutWeekRangeLabel,
        workoutCompletionHistory,
        mealCompletionHistory,
        missedWorkoutCount,
        missedMealCount,
      ];
}