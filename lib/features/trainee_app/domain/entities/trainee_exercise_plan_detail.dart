import 'package:equatable/equatable.dart';

/// One session (day) derived from plan detail — grouped by `sessionId` on exercises.
class TraineePlanSessionGroup extends Equatable {
  final String sessionId;
  final String title;
  final int dayOrder;
  final List<TraineeExerciseItem> exercises;

  const TraineePlanSessionGroup({
    required this.sessionId,
    required this.title,
    required this.dayOrder,
    required this.exercises,
  });

  @override
  List<Object?> get props => [sessionId, title, dayOrder, exercises];
}

bool traineeExerciseStatusIndicatesDone(String status) {
  final t = status.toLowerCase().trim();
  return t == 'completed' || t == 'complete' || t == 'done';
}

String traineePlanExerciseBucketKey(
  TraineeExerciseItem exercise,
  TraineeExercisePlanDetail detail,
) {
  final sid = exercise.sessionId?.trim();
  if (sid != null && sid.isNotEmpty) return sid;
  final fallback = detail.planSessionId?.trim();
  if (fallback != null && fallback.isNotEmpty) return fallback;
  return '__single__';
}

String traineeResolvedPlanSessionId(
  String bucketSessionId,
  TraineeExercisePlanDetail detail,
) {
  if (bucketSessionId == '__single__') {
    return detail.planSessionId?.trim() ?? '';
  }
  return bucketSessionId;
}

/// Groups [detail.exercises] into ordered sessions (by `dayOrder`, then id).
List<TraineePlanSessionGroup> buildTraineePlanSessionGroups(
  TraineeExercisePlanDetail detail,
) {
  if (detail.exercises.isEmpty) return [];

  final map = <String, List<TraineeExerciseItem>>{};
  for (final e in detail.exercises) {
    final k = traineePlanExerciseBucketKey(e, detail);
    map.putIfAbsent(k, () => []).add(e);
  }

  final groups = map.entries.map((entry) {
    final list = List<TraineeExerciseItem>.from(entry.value)
      ..sort((a, b) => a.order.compareTo(b.order));

    var minDay = 1 << 30;
    for (final e in list) {
      if (e.dayOrder < minDay) minDay = e.dayOrder;
    }
    if (minDay > (1 << 29)) minDay = 0;

    String title = '';
    for (final e in list) {
      final st = e.sessionTitle?.trim();
      if (st != null && st.isNotEmpty) {
        title = st;
        break;
      }
    }
    if (title.isEmpty) {
      title = 'Day ${minDay + 1}';
    }

    return TraineePlanSessionGroup(
      sessionId: entry.key,
      title: title,
      dayOrder: minDay,
      exercises: list,
    );
  }).toList();

  groups.sort((a, b) {
    final c = a.dayOrder.compareTo(b.dayOrder);
    if (c != 0) return c;
    return a.sessionId.compareTo(b.sessionId);
  });

  return groups;
}

/// `sessionId` / `planSessionId` → trainee has completed that session (coach-visible on backend).
Map<String, bool> parsePlanSessionCompletionFlags(Map<String, dynamic> json) {
  final out = <String, bool>{};
  void absorb(List? list) {
    if (list == null) return;
    for (final raw in list) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final sid = m['sessionId']?.toString() ??
          m['planSessionId']?.toString() ??
          m['id']?.toString();
      if (sid == null || sid.isEmpty) continue;
      final st = m['status']?.toString().toLowerCase() ?? '';
      final done = m['completed'] == true ||
          m['completedToday'] == true ||
          m['done'] == true ||
          st == 'completed' ||
          st == 'complete' ||
          st == 'done';
      out[sid] = done;
    }
  }

  absorb(json['sessions'] as List?);
  absorb(json['planSessions'] as List?);
  absorb(json['workoutSessions'] as List?);
  absorb(json['days'] as List?);
  absorb(json['weeklySessions'] as List?);
  return out;
}

class TraineeExercisePlanDetail extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String difficulty;
  final int exercisesTotal;
  final int durationMinutes;
  final int estimatedCalories;
  final int setsTotal;
  final String coachNote;
  final List<TraineeExerciseItem> exercises;

  /// When the API exposes a single active session on the plan payload.
  final String? planSessionId;

  /// From `sessions` / `planSessions` on the plan detail response (backend completion).
  final Map<String, bool> sessionCompletionBySessionId;

  const TraineeExercisePlanDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.exercisesTotal,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.setsTotal,
    required this.coachNote,
    required this.exercises,
    this.planSessionId,
    this.sessionCompletionBySessionId = const {},
  });

  factory TraineeExercisePlanDetail.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TraineeExercisePlanDetail(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      difficulty: json['difficulty'] ?? '',
      exercisesTotal: toInt(json['exercisesTotal']),
      durationMinutes: toInt(json['durationMinutes']),
      estimatedCalories: toInt(json['estimatedCalories']),
      setsTotal: toInt(json['setsTotal']),
      coachNote: json['coachNote'] ?? json['description'] ?? '',
      planSessionId: _inferPlanSessionId(json),
      sessionCompletionBySessionId: parsePlanSessionCompletionFlags(json),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => TraineeExerciseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String? _inferPlanSessionId(Map<String, dynamic> json) {
    final direct = json['planSessionId']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;

    final list = json['exercises'] as List? ?? [];
    final ids = list
        .map((e) => (e as Map)['sessionId']?.toString())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet();
    if (ids.length == 1) return ids.first;
    return null;
  }

  /// Exercises for one session, with [planSessionId] set for completion APIs.
  TraineeExercisePlanDetail sliceForSessionBucket(String bucketSessionId) {
    final ex = exercises
        .where((e) => traineePlanExerciseBucketKey(e, this) == bucketSessionId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final resolved = traineeResolvedPlanSessionId(bucketSessionId, this);

    return TraineeExercisePlanDetail(
      id: id,
      title: title,
      subtitle: subtitle,
      difficulty: difficulty,
      exercisesTotal: ex.length,
      durationMinutes: durationMinutes,
      estimatedCalories: estimatedCalories,
      setsTotal: setsTotal,
      coachNote: coachNote,
      exercises: ex,
      planSessionId: resolved.isNotEmpty ? resolved : planSessionId,
      sessionCompletionBySessionId: sessionCompletionBySessionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        difficulty,
        exercisesTotal,
        durationMinutes,
        estimatedCalories,
        setsTotal,
        coachNote,
        exercises,
        planSessionId,
        sessionCompletionBySessionId,
      ];
}

class TraineeExerciseItem extends Equatable {
  /// v1: `planSessionExerciseId` (UUID string).
  final String id;
  final int order;
  final String name;
  final int sets;
  final String reps;
  final String? load;
  final String rest;
  final String muscleGroup;
  final String status;
  final String? videoUrl;
  final String? sessionId;
  final String? sessionTitle;
  final int dayOrder;

  const TraineeExerciseItem({
    required this.id,
    required this.order,
    required this.name,
    required this.sets,
    required this.reps,
    required this.load,
    required this.rest,
    required this.muscleGroup,
    required this.status,
    this.videoUrl,
    this.sessionId,
    this.sessionTitle,
    this.dayOrder = 0,
  });

  factory TraineeExerciseItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    final lineId = json['planSessionExerciseId']?.toString() ??
        json['id']?.toString() ??
        '';

    return TraineeExerciseItem(
      id: lineId,
      order: toInt(json['order'] ?? json['orderIndex']),
      name: json['name'] ?? '',
      sets: toInt(json['sets']),
      reps: json['reps']?.toString() ?? '',
      load: json['load']?.toString(),
      rest: json['rest']?.toString() ?? '',
      muscleGroup: json['muscleGroup'] ?? '',
      status: json['status'] ?? 'not_started',
      videoUrl: json['videoUrl']?.toString(),
      sessionId: json['sessionId']?.toString(),
      sessionTitle: json['sessionTitle']?.toString(),
      dayOrder: toInt(json['dayOrder']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        sets,
        reps,
        load,
        rest,
        muscleGroup,
        status,
        videoUrl,
        sessionId,
        sessionTitle,
        dayOrder,
      ];
}
