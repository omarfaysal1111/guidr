import 'package:equatable/equatable.dart';
import 'coach_trainee_plans_data.dart';

/// One logged set for coach preview (`setDetails` / `sets` on workout log APIs).
class CoachTraineeWorkoutSetDetail extends Equatable {
  final int setNumber;
  /// `COMPLETED` | `SKIPPED` | `MISSED` (or legacy booleans inferred in [fromJson]).
  final String outcome;
  final String? reason;
  /// Logged load for this set (kg), when API sends `weight` / `weightKg` on each set row.
  final double? weightKg;
  /// Actual reps performed for this set.
  final int? reps;

  const CoachTraineeWorkoutSetDetail({
    required this.setNumber,
    required this.outcome,
    this.reason,
    this.weightKg,
    this.reps,
  });

  bool get isCompleted => outcome.toUpperCase() == 'COMPLETED';
  bool get isSkipped => outcome.toUpperCase() == 'SKIPPED';
  bool get isMissed => outcome.toUpperCase() == 'MISSED';

  factory CoachTraineeWorkoutSetDetail.fromJson(Map<String, dynamic> m) {
    final sn = CoachTraineeWorkoutExerciseLog._readInt(m, [
      'setNumber',
      'setNum',
      'index',
      'setIndex',
    ], 1);
    var outcome = m['outcome']?.toString().toUpperCase().trim() ?? '';
    if (outcome.isEmpty) {
      if (m['missed'] == true) {
        outcome = 'MISSED';
      } else if (m['skipped'] == true) {
        outcome = 'SKIPPED';
      } else if (m['completed'] == true ||
          m['done'] == true ||
          m['isCompleted'] == true ||
          m['logged'] == true) {
        outcome = 'COMPLETED';
      } else {
        final st = m['status']?.toString().toUpperCase().trim() ?? '';
        outcome = st.isNotEmpty ? st : 'COMPLETED';
      }
    }
    final reason = m['reason']?.toString() ?? m['skipReason']?.toString();
    final repsRaw = m['reps'] ?? m['actualReps'] ?? m['loggedReps'] ?? m['repsCompleted'];
    final reps = repsRaw is num
        ? repsRaw.toInt()
        : int.tryParse(repsRaw?.toString() ?? '');
    return CoachTraineeWorkoutSetDetail(
      setNumber: sn,
      outcome: outcome,
      reason: reason != null && reason.trim().isEmpty ? null : reason?.trim(),
      weightKg: _readSetWeightKg(m),
      reps: reps,
    );
  }

  static double? _readSetWeightKg(Map<String, dynamic> m) {
    const keys = [
      'weight',
      'weightKg',
      'weight_kg',
      'wieghtKg',
      'loadKg',
      'load',
      'loggedWeight',
      'actualWeight',
    ];
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v.toDouble();
      if (v is String && v.trim().isNotEmpty) {
        final p = double.tryParse(v.trim().replaceAll(',', '.'));
        if (p != null) return p;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [setNumber, outcome, reason, weightKg, reps];
}

/// Logged exercise row for a single day (coach trainee API).
class CoachTraineeWorkoutExerciseLog extends Equatable {
  final String name;
  final String status; // COMPLETED, PARTIAL, SKIPPED, UPCOMING
  final int setsDone;
  final int setsPlanned;
  final String? skipReason;
  final double wieghtKg ; 
  /// Per-set breakdown when API sends `setDetails` or per-set `sets` / `setLogs`.
  final List<CoachTraineeWorkoutSetDetail>? setDetails;

  const CoachTraineeWorkoutExerciseLog({
    required this.name,
    required this.status,
    required this.setsDone,
    required this.setsPlanned,
    required this.wieghtKg,
    this.skipReason,
    this.setDetails,
  });

  bool get isSkipped => status.toUpperCase() == 'SKIPPED';
  bool get isPartial {
    final u = status.toUpperCase();
    return u == 'PARTIAL' ||
        u == 'IN_PROGRESS' ||
        (setsPlanned > 0 && setsDone > 0 && setsDone < setsPlanned);
  }

  /// True when this exercise clearly has logged work (for headers when API omits planned sets).
  bool get hasLoggedSetsWork {
    if (isSkipped) return false;
    if (setsDone > 0) return true;
    final u = status.toUpperCase();
    return u == 'COMPLETED' ||
        u == 'DONE' ||
        u == 'COMPLETE' ||
        u == 'PARTIAL' ||
        u == 'IN_PROGRESS';
  }

  /// True when we treat the exercise as fully completed for x/y summaries.
  bool get countsAsExerciseCompleted {
    if (isSkipped) return false;
    final u = status.toUpperCase();
    if (u == 'COMPLETED' || u == 'DONE' || u == 'COMPLETE') return true;
    if (setsPlanned > 0 && setsDone >= setsPlanned) return true;
    if (setsPlanned <= 0 && setsDone > 0) return true;
    return false;
  }

  /// Per-row sets text when planned count is missing from API.
  String get setsDisplayLabel {
    if (isSkipped) return '';
    if (setsPlanned > 0) return '$setsDone/$setsPlanned';
    if (setsDone > 0) return '$setsDone sets';
    final u = status.toUpperCase();
    if (u == 'COMPLETED' || u == 'DONE' || u == 'COMPLETE') return 'Done';
    if (u == 'PARTIAL' || u == 'IN_PROGRESS') return 'Partial';
    return '0/0';
  }

  factory CoachTraineeWorkoutExerciseLog.fromJson(Map<String, dynamic> json) {
    final flat = _flattenExerciseJson(json);
    final statusRaw =
        flat['status']?.toString() ?? flat['state']?.toString() ?? 'UPCOMING';
    var done = _readInt(flat, [
      'setsDone',
      'completedSets',
      'doneSets',
      'setsCompleted',
      'completedSetCount',
      'setsCompletedCount',
      'numSetsCompleted',
      'actualSets',
      'performedSets',
    ]);
    var planned = _readInt(flat, [
      'setsPlanned',
      'plannedSets',
      'targetSets',
      'totalSets',
      'setCount',
      'numberOfSets',
      'prescribedSets',
      'targetSetCount',
      'plannedSetCount',
    ], 0);

    final fromList = _countSetsFromSetsArray(flat['sets'] ?? flat['setLogs'] ?? flat['loggedSets']);
    if (fromList != null) {
      if (planned <= 0) {
        planned = fromList.$2;
      }
      if (done <= 0) {
        done = fromList.$1;
      } else if (done < fromList.$1) {
        done = fromList.$1;
      }
    }

    final u = statusRaw.toUpperCase();
    if (planned <= 0 && done > 0) {
      planned = done;
    }
    if (done <= 0 &&
        planned > 0 &&
        (u == 'COMPLETED' || u == 'DONE' || u == 'COMPLETE')) {
      done = planned;
    }

    final directSkip = flat['skipReason']?.toString() ??
        flat['skippedReason']?.toString() ??
        flat['reason']?.toString();
    final fromSets = _skipReasonFromPerSetLogs(
        flat['sets'] ?? flat['setLogs'] ?? flat['loggedSets']);
    final mergedSkip = (directSkip != null && directSkip.trim().isNotEmpty)
        ? directSkip.trim()
        : fromSets;

    final setDetails = _parseSetDetailsList(
        flat['setDetails'] ?? flat['sets'] ?? flat['setLogs'] ?? flat['loggedSets']);

    return CoachTraineeWorkoutExerciseLog(
      wieghtKg: flat['wieghtKg'] is num ? (flat['wieghtKg'] as num).toDouble() : 0.0,
      name: flat['name']?.toString() ??
          flat['exerciseName']?.toString() ??
          flat['title']?.toString() ??
          'Exercise',
      status: statusRaw,
      setsDone: done,
      setsPlanned: planned,
      skipReason: mergedSkip,
      setDetails: setDetails,
    );
  }

  static List<CoachTraineeWorkoutSetDetail>? _parseSetDetailsList(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final out = <CoachTraineeWorkoutSetDetail>[];
    var i = 0;
    for (final s in raw) {
      if (s is! Map) continue;
      i++;
      final m = Map<String, dynamic>.from(s);
      if (!m.containsKey('setNumber') &&
          !m.containsKey('setNum') &&
          !m.containsKey('index') &&
          !m.containsKey('setIndex')) {
        m['setNumber'] = i;
      }
      out.add(CoachTraineeWorkoutSetDetail.fromJson(m));
    }
    return out.isEmpty ? null : out;
  }

  /// When the API returns per-set rows (e.g. after trainee session completion).
  static String? _skipReasonFromPerSetLogs(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final parts = <String>[];
    for (final s in raw) {
      if (s is! Map) continue;
      final m = Map<String, dynamic>.from(s);
      final outcome = m['outcome']?.toString().toUpperCase() ?? '';
      final isSkipped = m['skipped'] == true || outcome == 'SKIPPED';
      final isMissed = m['missed'] == true || outcome == 'MISSED';
      if (!isSkipped && !isMissed) continue;
      final r =
          (m['skipReason'] ?? m['reason'])?.toString().trim() ?? '';
      final sn = m['setNumber'] ?? m['index'] ?? m['setIndex'];
      final tag = isMissed ? 'missed' : 'skipped';
      if (r.isNotEmpty) {
        parts.add(sn != null ? 'Set $sn ($tag): $r' : '$tag: $r');
      } else {
        parts.add(sn != null ? 'Set $sn $tag' : 'Set $tag');
      }
    }
    if (parts.isEmpty) return null;
    return parts.join('; ');
  }

  static Map<String, dynamic> _flattenExerciseJson(Map<String, dynamic> json) {
    final out = Map<String, dynamic>.from(json);
    const nested = [
      'progress',
      'stats',
      'completion',
      'summary',
      'log',
      'performance',
    ];
    for (final k in nested) {
      final n = json[k];
      if (n is Map<String, dynamic>) {
        for (final e in n.entries) {
          out.putIfAbsent(e.key, () => e.value);
        }
      }
    }
    return out;
  }

  /// Returns (completedCount, totalCount) from a list of set objects.
  static (int, int)? _countSetsFromSetsArray(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    var total = 0;
    var done = 0;
    for (final s in raw) {
      if (s is! Map) continue;
      total++;
      final m = Map<String, dynamic>.from(s);
      final c = m['completed'] == true ||
          m['done'] == true ||
          m['isCompleted'] == true ||
          m['logged'] == true ||
          (m['status']?.toString().toUpperCase() == 'COMPLETED');
      if (c) done++;
    }
    if (total == 0) return null;
    return (done, total);
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

  @override
  List<Object?> get props =>
      [name, status, setsDone, setsPlanned, skipReason, setDetails];
}

/// One day's workout session with exercise breakdown.
class CoachTraineeWorkoutDaySession extends Equatable {
  final int weekday;
  final CoachTraineeWorkoutDayVisual stripVisual;
  /// COMPLETED | PARTIAL | MISSED | UPCOMING | REST
  final String sessionStatus;
  final int? durationMinutes;
  final int exercisesDone;
  final int exercisesPlanned;
  final String? traineeDayNote;
  final List<CoachTraineeWorkoutExerciseLog> exercises;

  const CoachTraineeWorkoutDaySession({
    required this.weekday,
    required this.stripVisual,
    required this.sessionStatus,
    this.durationMinutes,
    required this.exercisesDone,
    required this.exercisesPlanned,
    this.traineeDayNote,
    required this.exercises,
  });

  bool get hasExerciseBreakdown => exercises.isNotEmpty;

  @override
  List<Object?> get props => [
        weekday,
        stripVisual,
        sessionStatus,
        durationMinutes,
        exercisesDone,
        exercisesPlanned,
        traineeDayNote,
        exercises,
      ];
}

/// Skipped set row from `recentSkippedSets` on coach trainee detail.
class CoachTraineeSkippedSetRecord extends Equatable {
  final int? weekday;
  final String? exerciseName;
  final String? reason;
  final int? setsSkipped;
  final String? sessionDate;
  final int? plannedSets;

  const CoachTraineeSkippedSetRecord({
    this.weekday,
    this.exerciseName,
    this.reason,
    this.setsSkipped,
    this.sessionDate,
    this.plannedSets,
  });

  factory CoachTraineeSkippedSetRecord.fromJson(Map<String, dynamic> json) {
    int? wd = json['weekday'] is int ? json['weekday'] as int : int.tryParse('${json['weekday']}');
    if (wd != null && (wd < 1 || wd > 7)) wd = null;
    return CoachTraineeSkippedSetRecord(
      weekday: wd,
      exerciseName: json['exerciseName']?.toString() ?? json['name']?.toString(),
      reason: json['reason']?.toString() ??
          json['skipReason']?.toString() ??
          json['traineeReason']?.toString(),
      setsSkipped: json['setsSkipped'] is int
          ? json['setsSkipped'] as int
          : int.tryParse('${json['setsSkipped']}'),
      sessionDate: json['sessionDate']?.toString() ?? json['date']?.toString(),
      plannedSets: json['setsPlanned'] is int
          ? json['setsPlanned'] as int
          : int.tryParse('${json['setsPlanned']}'),
    );
  }

  @override
  List<Object?> get props => [weekday, exerciseName, reason, setsSkipped, sessionDate, plannedSets];
}

int? _weekdayFromIsoDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  return d?.weekday;
}

List<CoachTraineeSkippedSetRecord> parseSkippedSetsList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(CoachTraineeSkippedSetRecord.fromJson)
      .toList();
}

/// Collect exercise maps from a day session (blocks, nested lists, etc.).
List<Map<String, dynamic>> _exerciseMapsFromSession(Map<String, dynamic> e) {
  final out = <Map<String, dynamic>>[];
  void addList(dynamic list) {
    if (list is! List) return;
    for (final x in list) {
      if (x is Map<String, dynamic>) {
        out.add(x);
      } else if (x is Map) {
        out.add(Map<String, dynamic>.from(x));
      }
    }
  }

  addList(e['exercises']);
  addList(e['items']);
  addList(e['movements']);
  addList(e['exerciseLogs']);
  addList(e['loggedExercises']);
  addList(e['workoutExercises']);

  final blocks = e['blocks'];
  if (blocks is List) {
    for (final b in blocks) {
      if (b is! Map) continue;
      final bm = Map<String, dynamic>.from(b);
      addList(bm['exercises']);
      addList(bm['items']);
      addList(bm['movements']);
    }
  }
  return out;
}

int _countNonSkippedExercises(List<CoachTraineeWorkoutExerciseLog> list) {
  return list.where((e) => !e.isSkipped).length;
}

int _countExercisesCompletedForSummary(List<CoachTraineeWorkoutExerciseLog> list) {
  return list.where((e) => e.countsAsExerciseCompleted).length;
}

List<CoachTraineeWorkoutDaySession> parseWorkoutDaySessionsList(dynamic raw) {
  if (raw is! List) return [];
  final out = <CoachTraineeWorkoutDaySession>[];
  for (final e in raw) {
    if (e is! Map<String, dynamic>) continue;
    final wd = CoachTraineeWorkoutProgress.tryParseWeekday(
        e['weekday'] ?? e['day'] ?? e['dayOfWeek']);
    if (wd == null) continue;
    final exerciseMaps = _exerciseMapsFromSession(e);
    final exercises =
        exerciseMaps.map(CoachTraineeWorkoutExerciseLog.fromJson).toList();
    var done = _readInt(e, [
      'exercisesCompleted',
      'completedExercises',
      'exercisesDone',
      'completedExerciseCount',
    ]);
    var planned = _readInt(e, [
      'exercisesPlanned',
      'plannedExercises',
      'exercisesTarget',
      'totalExercises',
    ]);
    if (exercises.isNotEmpty) {
      final cd = _countExercisesCompletedForSummary(exercises);
      final cp = _countNonSkippedExercises(exercises);
      if (done == 0 && planned == 0) {
        done = cd;
        planned = cp;
      } else {
        if (planned == 0 && cp > 0) planned = cp;
        if (done == 0 && cd > 0) done = cd;
      }
    }
    final status = e['status']?.toString() ?? e['sessionStatus']?.toString() ?? 'UPCOMING';
    final visual = CoachTraineeWorkoutProgress.visualForStatusString(status);
    out.add(CoachTraineeWorkoutDaySession(
      weekday: wd,
      stripVisual: visual,
      sessionStatus: status.toUpperCase(),
      durationMinutes: _readIntNullable(e, ['durationMinutes', 'duration', 'totalMinutes']),
      exercisesDone: done,
      exercisesPlanned: planned,
      traineeDayNote: e['traineeNote']?.toString() ??
          e['dailyNote']?.toString() ??
          e['note']?.toString(),
      exercises: exercises,
    ));
  }
  return out;
}

int _readInt(Map<String, dynamic> json, List<String> keys, [int fallback = 0]) {
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

int? _readIntNullable(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v == null) continue;
    if (v is int) return v;
    if (v is double) return v.round();
    final p = int.tryParse(v.toString());
    if (p != null) return p;
  }
  return null;
}

String _stripVisualToSessionStatus(CoachTraineeWorkoutDayVisual v) {
  switch (v) {
    case CoachTraineeWorkoutDayVisual.completed:
      return 'COMPLETED';
    case CoachTraineeWorkoutDayVisual.partial:
      return 'PARTIAL';
    case CoachTraineeWorkoutDayVisual.missed:
      return 'MISSED';
    case CoachTraineeWorkoutDayVisual.rest:
      return 'REST';
    case CoachTraineeWorkoutDayVisual.upcoming:
      return 'UPCOMING';
  }
}

/// Merges API day sessions + [recentSkippedSets] with the weekly strip from [wp].
List<CoachTraineeWorkoutDaySession> buildMergedWorkoutWeek({
  required CoachTraineeWorkoutProgress wp,
  required List<CoachTraineeWorkoutDaySession> apiSessions,
  required List<CoachTraineeSkippedSetRecord> skippedSets,
}) {
  final byWd = {for (final s in apiSessions) s.weekday: s};
  final result = <CoachTraineeWorkoutDaySession>[];

  for (var wd = 1; wd <= 7; wd++) {
    final strip = wp.days[wd - 1];
    final skipsForDay = skippedSets.where((s) {
      final w = s.weekday ?? _weekdayFromIsoDate(s.sessionDate);
      return w == wd;
    });

    List<CoachTraineeWorkoutExerciseLog> exercises;
    int exDone;
    int exPlanned;
    int? duration;
    String? dayNote;
    String sessionStatus;

    if (byWd.containsKey(wd)) {
      final api = byWd[wd]!;
      exercises = List<CoachTraineeWorkoutExerciseLog>.from(api.exercises);
      exDone = api.exercisesDone;
      exPlanned = api.exercisesPlanned;
      duration = api.durationMinutes;
      dayNote = api.traineeDayNote;
      sessionStatus = api.sessionStatus;
    } else {
      exercises = [];
      exDone = 0;
      exPlanned = 0;
      duration = null;
      dayNote = null;
      sessionStatus = _stripVisualToSessionStatus(strip.visual);
    }

    for (final sk in skipsForDay) {
      final en = (sk.exerciseName ?? '').trim().toLowerCase();
      if (en.isNotEmpty &&
          exercises.any((e) => e.name.trim().toLowerCase() == en)) {
        continue;
      }
      final planned = sk.plannedSets ?? sk.setsSkipped ?? 1;
      exercises.add(CoachTraineeWorkoutExerciseLog(
        name: sk.exerciseName ?? 'Exercise',
        wieghtKg: exercises.isNotEmpty ? exercises.first.wieghtKg : 0.0, // best effort to fill weight for skipped sets without duplication if multiple skips for the day
        status: 'SKIPPED',
        setsDone: sk.plannedSets!-sk.setsSkipped!,
        setsPlanned: planned > 0 ? planned : 1,
        skipReason: sk.reason,
      ));
    }

    if (exercises.isNotEmpty) {
      final computedPlanned = _countNonSkippedExercises(exercises);
      final computedDone = _countExercisesCompletedForSummary(exercises);

      if (exPlanned == 0 && exDone == 0) {
        exPlanned = computedPlanned;
        exDone = computedDone;
      } else {
        if (computedPlanned > exPlanned) exPlanned = computedPlanned;
        if (exDone == 0 && computedDone > 0) exDone = computedDone;
        if (exPlanned == 0 && computedPlanned > 0) exPlanned = computedPlanned;
      }
    }

    result.add(CoachTraineeWorkoutDaySession(
      weekday: wd,
      stripVisual: strip.visual,
      sessionStatus: sessionStatus,
      durationMinutes: duration,
      exercisesDone: exDone,
      exercisesPlanned: exPlanned,
      traineeDayNote: dayNote,
      exercises: exercises,
    ));
  }

  return result;
}

