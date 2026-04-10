import 'package:equatable/equatable.dart';
import 'coach_trainee_workout_sessions.dart';

/// One exercise line inside [CoachTraineeWorkoutCompletionRecord] (`exerciseLogs[]`).
class CoachTraineeCompletionExerciseLog extends Equatable {
  final String logId;
  final String planSessionExerciseId;
  final String exerciseName;
  final int plannedSets;
  final int actualSetsCompleted;
  final int skippedSets;
  final int missedSets;
  final bool allSetsCompleted;
  final String? excuse;
  final String? coachNotes;
  final bool isReviewedByCoach;
  final DateTime? loggedAt;
  final List<CoachTraineeWorkoutSetDetail> setDetails;

  const CoachTraineeCompletionExerciseLog({
    required this.logId,
    required this.planSessionExerciseId,
    required this.exerciseName,
    required this.plannedSets,
    required this.actualSetsCompleted,
    required this.skippedSets,
    required this.missedSets,
    required this.allSetsCompleted,
    this.excuse,
    this.coachNotes,
    required this.isReviewedByCoach,
    this.loggedAt,
    required this.setDetails,
  });

  factory CoachTraineeCompletionExerciseLog.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['setDetails'] ?? json['sets'] ?? json['setLogs'];
    final details = <CoachTraineeWorkoutSetDetail>[];
    if (detailsRaw is List) {
      for (final s in detailsRaw) {
        if (s is Map<String, dynamic>) {
          details.add(CoachTraineeWorkoutSetDetail.fromJson(s));
        } else if (s is Map) {
          details.add(CoachTraineeWorkoutSetDetail.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    return CoachTraineeCompletionExerciseLog(
      logId: json['logId']?.toString() ?? '',
      planSessionExerciseId: json['planSessionExerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ??
          json['name']?.toString() ??
          'Exercise',
      plannedSets: _toInt(json['plannedSets']),
      actualSetsCompleted: _toInt(json['actualSetsCompleted']),
      skippedSets: _toInt(json['skippedSets']),
      missedSets: _toInt(json['missedSets']),
      allSetsCompleted: json['allSetsCompleted'] == true,
      excuse: json['excuse']?.toString(),
      coachNotes: json['coachNotes']?.toString(),
      isReviewedByCoach: json['isReviewedByCoach'] == true,
      loggedAt: _parseDateTime(json['loggedAt']),
      setDetails: details,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  /// Maps API completion row to the shared coach exercise log model (Plans tab UI).
  CoachTraineeWorkoutExerciseLog toWorkoutExerciseLog() {
    final status = _deriveStatus();
    return CoachTraineeWorkoutExerciseLog(
      name: exerciseName,
      status: status,
      setsDone: actualSetsCompleted,
      setsPlanned: plannedSets,
      skipReason: excuse,
      setDetails: setDetails.isEmpty ? null : List<CoachTraineeWorkoutSetDetail>.from(setDetails),
    );
  }

  String _deriveStatus() {
    if (allSetsCompleted) return 'COMPLETED';
    if (plannedSets > 0 &&
        actualSetsCompleted == 0 &&
        skippedSets + missedSets >= plannedSets) {
      return 'SKIPPED';
    }
    if (actualSetsCompleted < plannedSets ||
        skippedSets > 0 ||
        missedSets > 0) {
      return 'PARTIAL';
    }
    return 'COMPLETED';
  }

  @override
  List<Object?> get props => [
        logId,
        planSessionExerciseId,
        exerciseName,
        plannedSets,
        actualSetsCompleted,
        skippedSets,
        missedSets,
        allSetsCompleted,
        excuse,
        coachNotes,
        isReviewedByCoach,
        loggedAt,
        setDetails,
      ];
}

/// One saved session completion from `workoutCompletionHistory` on coach trainee detail.
class CoachTraineeWorkoutCompletionRecord extends Equatable {
  final String completionId;
  final String planSessionId;
  final String? planSessionTitle;
  final String workoutPlanId;
  final String? workoutPlanTitle;
  final int dayOrder;
  final String completionDate;
  final DateTime? completedAt;
  final bool hasDetailedLogs;
  final List<CoachTraineeCompletionExerciseLog> exerciseLogs;

  const CoachTraineeWorkoutCompletionRecord({
    required this.completionId,
    required this.planSessionId,
    this.planSessionTitle,
    required this.workoutPlanId,
    this.workoutPlanTitle,
    required this.dayOrder,
    required this.completionDate,
    this.completedAt,
    required this.hasDetailedLogs,
    required this.exerciseLogs,
  });

  factory CoachTraineeWorkoutCompletionRecord.fromJson(Map<String, dynamic> json) {
    final logsRaw = json['exerciseLogs'];
    final logs = <CoachTraineeCompletionExerciseLog>[];
    if (logsRaw is List) {
      for (final e in logsRaw) {
        if (e is Map<String, dynamic>) {
          logs.add(CoachTraineeCompletionExerciseLog.fromJson(e));
        } else if (e is Map) {
          logs.add(CoachTraineeCompletionExerciseLog.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return CoachTraineeWorkoutCompletionRecord(
      completionId: json['completionId']?.toString() ?? '',
      planSessionId: json['planSessionId']?.toString() ?? '',
      planSessionTitle: json['planSessionTitle']?.toString(),
      workoutPlanId: json['workoutPlanId']?.toString() ?? '',
      workoutPlanTitle: json['workoutPlanTitle']?.toString(),
      dayOrder: CoachTraineeCompletionExerciseLog._toInt(json['dayOrder']),
      completionDate: json['completionDate']?.toString().trim() ?? '',
      completedAt: CoachTraineeCompletionExerciseLog._parseDateTime(json['completedAt']),
      hasDetailedLogs: json['hasDetailedLogs'] == true,
      exerciseLogs: logs,
    );
  }

  @override
  List<Object?> get props => [
        completionId,
        planSessionId,
        planSessionTitle,
        workoutPlanId,
        workoutPlanTitle,
        dayOrder,
        completionDate,
        completedAt,
        hasDetailedLogs,
        exerciseLogs,
      ];
}

List<CoachTraineeWorkoutCompletionRecord> parseWorkoutCompletionHistory(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(CoachTraineeWorkoutCompletionRecord.fromJson)
      .toList();
}
