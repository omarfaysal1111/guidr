import 'package:equatable/equatable.dart';

/// Visual state for one day in the coach trainee workout week strip.
enum CoachTraineeWorkoutDayVisual {
  completed,
  partial,
  missed,
  upcoming,
  rest,
}

/// One day in the workout week (Mon=1 … Sun=7).
class CoachTraineeWorkoutDayEntry extends Equatable {
  final int weekday;
  final CoachTraineeWorkoutDayVisual visual;

  const CoachTraineeWorkoutDayEntry({
    required this.weekday,
    required this.visual,
  });

  @override
  List<Object?> get props => [weekday, visual];
}

/// Workout progress summary for the Plans tab (from coach trainee detail API).
class CoachTraineeWorkoutProgress extends Equatable {
  /// Completed count (this week, or today — see [countsForToday]).
  final int completedThisWeek;
  /// Target count (this week, or today — see [countsForToday]).
  final int targetThisWeek;
  final int adherencePercent;
  final bool dataFromTrainee;
  final List<CoachTraineeWorkoutDayEntry> days;
  /// When true, [completedThisWeek]/[targetThisWeek] are **today’s** totals (`workoutsCompletedToday` / `workoutsPlannedToday`).
  final bool countsForToday;

  const CoachTraineeWorkoutProgress({
    required this.completedThisWeek,
    required this.targetThisWeek,
    required this.adherencePercent,
    required this.dataFromTrainee,
    required this.days,
    this.countsForToday = false,
  });

  static CoachTraineeWorkoutDayVisual _mapWorkoutStatus(String? raw) {
    if (raw == null || raw.isEmpty) return CoachTraineeWorkoutDayVisual.upcoming;
    switch (raw.toUpperCase().replaceAll(' ', '_')) {
      case 'COMPLETED':
      case 'DONE':
      case 'COMPLETE':
        return CoachTraineeWorkoutDayVisual.completed;
      case 'PARTIAL':
      case 'IN_PROGRESS':
        return CoachTraineeWorkoutDayVisual.partial;
      case 'MISSED':
      case 'SKIPPED':
      case 'FAILED':
        return CoachTraineeWorkoutDayVisual.missed;
      case 'REST':
      case 'OFF':
        return CoachTraineeWorkoutDayVisual.rest;
      case 'UPCOMING':
      case 'PENDING':
      case 'SCHEDULED':
      default:
        return CoachTraineeWorkoutDayVisual.upcoming;
    }
  }

  /// Public for workout session parsers (`coach_trainee_workout_sessions.dart`).
  static int? tryParseWeekday(dynamic v) => _parseWeekday(v);

  /// Map API session status string to strip visual.
  static CoachTraineeWorkoutDayVisual visualForStatusString(String? raw) =>
      _mapWorkoutStatus(raw);

  static int? _parseWeekday(dynamic v) {
    if (v == null) return null;
    if (v is int && v >= 1 && v <= 7) return v;
    if (v is String) {
      const map = {
        'MON': 1,
        'MONDAY': 1,
        'TUE': 2,
        'TUES': 2,
        'TUESDAY': 2,
        'WED': 3,
        'WEDNESDAY': 3,
        'THU': 4,
        'THUR': 4,
        'THURSDAY': 4,
        'FRI': 5,
        'FRIDAY': 5,
        'SAT': 6,
        'SATURDAY': 6,
        'SUN': 7,
        'SUNDAY': 7,
      };
      final u = v.toUpperCase().trim();
      return map[u];
    }
    return int.tryParse(v.toString());
  }

  static List<CoachTraineeWorkoutDayEntry> _parseDays(dynamic list) {
    if (list is! List) return [];
    final out = <CoachTraineeWorkoutDayEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final wd = _parseWeekday(e['weekday'] ?? e['day'] ?? e['dayOfWeek']);
      if (wd == null || wd < 1 || wd > 7) continue;
      final status = e['status']?.toString() ?? e['state']?.toString();
      out.add(CoachTraineeWorkoutDayEntry(weekday: wd, visual: _mapWorkoutStatus(status)));
    }
    return out;
  }

  static List<CoachTraineeWorkoutDayEntry> _fillWeek(List<CoachTraineeWorkoutDayEntry> parsed) {
    final byDay = {for (final d in parsed) d.weekday: d};
    return List.generate(7, (i) {
      final wd = i + 1;
      return byDay[wd] ?? CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.upcoming);
    });
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys, [int fallback = 0]) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is int) return v;
      if (v is double) return v.round();
      final p = int.tryParse(v.toString());
      if (p != null) return p;
    }
    return fallback;
  }

  static bool _readFromTrainee(Map<String, dynamic> json) {
    if (json['dataFromTrainee'] == true) return true;
    if (json['fromTrainee'] == true) return true;
    final s = json['source']?.toString().toUpperCase() ??
        json['progressSource']?.toString().toUpperCase() ??
        '';
    return s.contains('TRAINEE');
  }

  factory CoachTraineeWorkoutProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return CoachTraineeWorkoutProgress(
        completedThisWeek: 0,
        targetThisWeek: 0,
        adherencePercent: 0,
        dataFromTrainee: false,
        days: _fillWeek(const []),
      );
    }
    final completed = _readInt(json, ['completedThisWeek', 'completed', 'sessionsCompleted', 'doneThisWeek']);
    final target = _readInt(json, ['targetThisWeek', 'target', 'plannedSessions', 'sessionsTarget']);
    final adherence = _readInt(json, [
      'workoutProgressPercent',
      'adherencePercent',
      'adherence',
      'weekAdherencePercent',
    ]);
    final parsed = _parseDays(json['weekDays'] ?? json['days'] ?? json['daily']);
    return CoachTraineeWorkoutProgress(
      completedThisWeek: completed,
      targetThisWeek: target,
      adherencePercent: adherence,
      dataFromTrainee: _readFromTrainee(json),
      days: _fillWeek(parsed),
    );
  }

  /// Maps `GET /coaches/trainees/:id` → `profile` block (today’s workout stats + weekly %).
  factory CoachTraineeWorkoutProgress.fromCoachProfileMap(Map<String, dynamic> profile) {
    final completed = _readInt(profile, ['workoutsCompletedToday', 'workoutsCompleted']);
    final planned = _readInt(profile, ['workoutsPlannedToday', 'workoutsPlanned']);
    final adherence = _readInt(profile, [
      'workoutProgressPercent',
      'workoutAdherencePercent',
      'adherencePercent',
    ]);
    return CoachTraineeWorkoutProgress(
      completedThisWeek: completed,
      targetThisWeek: planned,
      adherencePercent: adherence,
      dataFromTrainee: true,
      days: _daysFromTodayWorkout(completed, planned),
      countsForToday: true,
    );
  }

  static List<CoachTraineeWorkoutDayEntry> _daysFromTodayWorkout(int completed, int planned) {
    final todayWd = DateTime.now().weekday;
    return List.generate(7, (i) {
      final wd = i + 1;
      if (wd != todayWd) {
        return CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.upcoming);
      }
      if (planned <= 0) {
        return CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.rest);
      }
      if (completed >= planned) {
        return CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.completed);
      }
      if (completed > 0) {
        return CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.partial);
      }
      return CoachTraineeWorkoutDayEntry(weekday: wd, visual: CoachTraineeWorkoutDayVisual.upcoming);
    });
  }

  @override
  List<Object?> get props =>
      [completedThisWeek, targetThisWeek, adherencePercent, dataFromTrainee, days, countsForToday];
}

/// One day in the nutrition week strip.
class CoachTraineeNutritionDayEntry extends Equatable {
  final int weekday;
  final int? mealsLogged;
  final int? mealsTarget;

  const CoachTraineeNutritionDayEntry({
    required this.weekday,
    this.mealsLogged,
    this.mealsTarget,
  });

  @override
  List<Object?> get props => [weekday, mealsLogged, mealsTarget];
}

class CoachTraineeNutritionProgress extends Equatable {
  final int mealsLogged;
  final int mealsTarget;
  final int adherencePercent;
  final bool dataFromTrainee;
  final List<CoachTraineeNutritionDayEntry> days;
  final double? avgWaterLitersPerDay;
  /// When true, [mealsLogged]/[mealsTarget] are **today’s** (`mealsCompletedToday` / `mealsPlannedToday`).
  final bool countsForToday;

  const CoachTraineeNutritionProgress({
    required this.mealsLogged,
    required this.mealsTarget,
    required this.adherencePercent,
    required this.dataFromTrainee,
    required this.days,
    this.avgWaterLitersPerDay,
    this.countsForToday = false,
  });

  static List<CoachTraineeNutritionDayEntry> _parseDays(dynamic list) {
    if (list is! List) return [];
    final out = <CoachTraineeNutritionDayEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final wd = CoachTraineeWorkoutProgress._parseWeekday(e['weekday'] ?? e['day'] ?? e['dayOfWeek']);
      if (wd == null || wd < 1 || wd > 7) continue;
      int? logged;
      int? target;
      final l = e['mealsLogged'] ?? e['logged'] ?? e['completed'];
      final t = e['mealsTarget'] ?? e['target'] ?? e['planned'];
      if (l != null) logged = int.tryParse(l.toString());
      if (t != null) target = int.tryParse(t.toString());
      out.add(CoachTraineeNutritionDayEntry(weekday: wd, mealsLogged: logged, mealsTarget: target));
    }
    return out;
  }

  static List<CoachTraineeNutritionDayEntry> _fillWeek(List<CoachTraineeNutritionDayEntry> parsed) {
    final byDay = {for (final d in parsed) d.weekday: d};
    return List.generate(7, (i) {
      final wd = i + 1;
      return byDay[wd] ?? CoachTraineeNutritionDayEntry(weekday: wd);
    });
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys, [int fallback = 0]) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is int) return v;
      if (v is double) return v.round();
      final p = int.tryParse(v.toString());
      if (p != null) return p;
    }
    return fallback;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final p = double.tryParse(v.toString());
      if (p != null) return p;
    }
    return null;
  }

  factory CoachTraineeNutritionProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return CoachTraineeNutritionProgress(
        mealsLogged: 0,
        mealsTarget: 0,
        adherencePercent: 0,
        dataFromTrainee: false,
        days: _fillWeek(const []),
        avgWaterLitersPerDay: null,
      );
    }
    final logged = _readInt(json, ['mealsLoggedThisWeek', 'mealsLogged', 'loggedMeals', 'completedMeals']);
    final target = _readInt(json, ['mealsTargetThisWeek', 'mealsTarget', 'targetMeals', 'plannedMeals']);
    final adherence = _readInt(json, [
      'nutritionProgressPercent',
      'adherencePercent',
      'nutritionAdherencePercent',
      'weekAdherencePercent',
    ]);
    final water = _readDouble(json, ['avgWaterLitersPerDay', 'averageWaterLitersPerDay', 'waterLitersPerDay', 'avgWaterL']);
    final parsed = _parseDays(json['weekDays'] ?? json['days'] ?? json['daily']);
    return CoachTraineeNutritionProgress(
      mealsLogged: logged,
      mealsTarget: target,
      adherencePercent: adherence,
      dataFromTrainee: CoachTraineeWorkoutProgress._readFromTrainee(json),
      days: _fillWeek(parsed),
      avgWaterLitersPerDay: water,
    );
  }

  factory CoachTraineeNutritionProgress.fromCoachProfileMap(Map<String, dynamic> profile) {
    final logged = _readInt(profile, ['mealsCompletedToday', 'mealsCompleted']);
    final planned = _readInt(profile, ['mealsPlannedToday', 'mealsPlanned']);
    final adherence = _readInt(profile, [
      'nutritionProgressPercent',
      'nutritionAdherencePercent',
      'adherencePercent',
    ]);
    final water = _readDouble(profile, [
      'avgWaterLitersPerDay',
      'averageWaterLitersPerDay',
      'waterLitersPerDay',
    ]);
    return CoachTraineeNutritionProgress(
      mealsLogged: logged,
      mealsTarget: planned,
      adherencePercent: adherence,
      dataFromTrainee: true,
      days: _daysFromTodayMeals(logged, planned),
      avgWaterLitersPerDay: water,
      countsForToday: true,
    );
  }

  static List<CoachTraineeNutritionDayEntry> _daysFromTodayMeals(int logged, int planned) {
    final todayWd = DateTime.now().weekday;
    return List.generate(7, (i) {
      final wd = i + 1;
      if (wd != todayWd) {
        return CoachTraineeNutritionDayEntry(weekday: wd);
      }
      if (planned <= 0 && logged <= 0) {
        return CoachTraineeNutritionDayEntry(weekday: wd);
      }
      return CoachTraineeNutritionDayEntry(
        weekday: wd,
        mealsLogged: logged,
        mealsTarget: planned > 0 ? planned : null,
      );
    });
  }

  @override
  List<Object?> get props => [
        mealsLogged,
        mealsTarget,
        adherencePercent,
        dataFromTrainee,
        days,
        avgWaterLitersPerDay,
        countsForToday,
      ];
}

// --- Optional prescribed preview (backend → `workoutPlans[]`) ----------------

/// One exercise line on a prescribed session preview.
class CoachTraineePlanExercisePreview extends Equatable {
  final String name;
  final int sets;
  final String? reps;
  final String? load;

  const CoachTraineePlanExercisePreview({
    required this.name,
    required this.sets,
    this.reps,
    this.load,
  });

  static int _readSets(Map<String, dynamic> json) {
    for (final k in ['sets', 'plannedSets', 'setCount', 'numberOfSets']) {
      final v = json[k];
      if (v is int) return v;
      final p = int.tryParse(v?.toString() ?? '');
      if (p != null) return p;
    }
    return 0;
  }

  factory CoachTraineePlanExercisePreview.fromJson(Map<String, dynamic> json) {
    return CoachTraineePlanExercisePreview(
      name: json['name']?.toString() ??
          json['exerciseName']?.toString() ??
          json['title']?.toString() ??
          'Exercise',
      sets: _readSets(json),
      reps: json['reps']?.toString(),
      load: json['load']?.toString(),
    );
  }

  @override
  List<Object?> get props => [name, sets, reps, load];
}

/// One session/day preview under an assigned plan (prescribed, not logged).
class CoachTraineePlanSessionPreview extends Equatable {
  final String? title;
  final int? dayOrder;
  final List<CoachTraineePlanExercisePreview> exercises;

  const CoachTraineePlanSessionPreview({
    this.title,
    this.dayOrder,
    required this.exercises,
  });

  factory CoachTraineePlanSessionPreview.fromJson(Map<String, dynamic> json) {
    final exRaw =
        json['exercises'] ?? json['lines'] ?? json['items'] ?? json['movements'];
    final exercises = <CoachTraineePlanExercisePreview>[];
    if (exRaw is List) {
      for (final x in exRaw) {
        if (x is Map<String, dynamic>) {
          exercises.add(CoachTraineePlanExercisePreview.fromJson(x));
        } else if (x is Map) {
          exercises
              .add(CoachTraineePlanExercisePreview.fromJson(Map<String, dynamic>.from(x)));
        }
      }
    }
    return CoachTraineePlanSessionPreview(
      title: json['title']?.toString() ?? json['name']?.toString(),
      dayOrder: int.tryParse(
          '${json['dayOrder'] ?? json['order'] ?? json['day'] ?? ''}'),
      exercises: exercises,
    );
  }

  @override
  List<Object?> get props => [title, dayOrder, exercises];
}

/// Single workout plan row on the Plans tab.
///
/// **Backend (optional):** to show prescribed exercises/sets on the coach Plans tab,
/// include on each `workoutPlans[]` item (see [sessionsPreview]):
/// - `sessionsPreview` (preferred) or `previewSessions`: list of
///   `{ "title"?, "dayOrder"?, "exercises": [ { "name", "sets", "reps"?, "load"? } ] }`.
///
/// **Logged per-set detail** for a completed day lives on
/// [CoachTraineeWorkoutExerciseLog.setDetails] in `coach_trainee_workout_sessions.dart`
/// (from `workoutDaySessions[].exercises[]`: `setDetails` or per-set `sets` / `setLogs`).
class CoachTraineeWorkoutPlanRow extends Equatable {
  final String id;
  final String title;
  final String status;
  final DateTime? assignedAt;
  /// Prescribed template: sessions → exercises → set counts (optional API field).
  final List<CoachTraineePlanSessionPreview>? sessionsPreview;

  const CoachTraineeWorkoutPlanRow({
    required this.id,
    required this.title,
    required this.status,
    this.assignedAt,
    this.sessionsPreview,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDraft => status.toUpperCase() == 'DRAFT';

  factory CoachTraineeWorkoutPlanRow.fromJson(Map<String, dynamic> json) {
    final idVal = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ??
        json['name']?.toString() ??
        json['planName']?.toString() ??
        'Plan';
    final status = json['status']?.toString() ?? 'DRAFT';
    DateTime? assigned;
    final raw = json['assignedAt'] ?? json['assigned_at'] ?? json['startDate'];
    if (raw is String && raw.isNotEmpty) {
      assigned = DateTime.tryParse(raw);
    }
    List<CoachTraineePlanSessionPreview>? preview;
    final prevRaw = json['sessionsPreview'] ??
        json['previewSessions'] ??
        json['sessionPreviews'] ??
        json['planSessionsPreview'];
    if (prevRaw is List && prevRaw.isNotEmpty) {
      final list = prevRaw
          .whereType<Map<String, dynamic>>()
          .map(CoachTraineePlanSessionPreview.fromJson)
          .toList();
      if (list.isNotEmpty) preview = list;
    }
    return CoachTraineeWorkoutPlanRow(
      id: idVal,
      title: title,
      status: status,
      assignedAt: assigned,
      sessionsPreview: preview,
    );
  }

  @override
  List<Object?> get props => [id, title, status, assignedAt, sessionsPreview];
}
