import '../entities/builder_exercise.dart';

/// Builds the JSON array for `POST /v1/workouts/{planSessionId}/exercises`.
class WorkoutPlanV1LineBuilder {
  static const _warmUp = 'WARM_UP';
  static const _main = 'MAIN';
  static const _coolDown = 'COOL_DOWN';

  /// Returns `null` if valid; otherwise a user-facing validation message.
  static String? validateAllFromCatalog({
    required List<BuilderExercise> warmUp,
    required List<BuilderExercise> main,
    required List<BuilderExercise> coolDown,
  }) {
    final missing = <String>[];
    void check(List<BuilderExercise> list, String label) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].exerciseId == null) {
          missing.add('$label #${i + 1} (${list[i].name})');
        }
      }
    }

    check(warmUp, 'Warm-up');
    check(main, 'Main');
    check(coolDown, 'Cool-down');
    if (missing.isEmpty) return null;
    return 'Each exercise must be chosen from the library (catalog id). '
        'Fix: ${missing.join(', ')}';
  }

  static List<Map<String, dynamic>> buildLines({
    required List<BuilderExercise> warmUp,
    required List<BuilderExercise> main,
    required List<BuilderExercise> coolDown,
  }) {
    final out = <Map<String, dynamic>>[];
    var order = 0;

    void addSection(String sectionType, List<BuilderExercise> items) {
      for (final ex in items) {
        final id = ex.exerciseId;
        if (id == null) continue;
        out.add({
          'exerciseId': id,
          'sectionType': sectionType,
          'orderIndex': order++,
          'sets': ex.sets,
          'reps': _parseReps(ex.reps),
          'loadAmount': _parseLoad(ex.load),
          'restSeconds': _parseRestSeconds(ex.rest),
        });
      }
    }

    addSection(_warmUp, warmUp);
    addSection(_main, main);
    addSection(_coolDown, coolDown);
    return out;
  }

  /// All lines use [MAIN] (flat list per session in the builder UI).
  static List<Map<String, dynamic>> buildMainLines(
      List<BuilderExercise> exercises) {
    final out = <Map<String, dynamic>>[];
    var order = 0;
    for (final ex in exercises) {
      final id = ex.exerciseId;
      if (id == null) continue;
      out.add({
        'exerciseId': id,
        'sectionType': _main,
        'orderIndex': order++,
        'sets': ex.sets,
        'reps': _parseReps(ex.reps),
        'loadAmount': _parseLoad(ex.load),
        'restSeconds': _parseRestSeconds(ex.rest),
      });
    }
    return out;
  }

  /// Returns `null` if every exercise has a catalog id.
  static String? validateSessionCatalog(
    List<BuilderExercise> exercises,
    String sessionLabel,
  ) {
    final missing = <String>[];
    for (var i = 0; i < exercises.length; i++) {
      if (exercises[i].exerciseId == null) {
        missing.add('#${i + 1} (${exercises[i].name})');
      }
    }
    if (missing.isEmpty) return null;
    return '$sessionLabel: each exercise must be from the library. Fix: ${missing.join(', ')}';
  }

  static int _parseReps(String reps) {
    final match = RegExp(r'\d+').firstMatch(reps.trim());
    if (match != null) return int.tryParse(match.group(0)!) ?? 10;
    return 10;
  }

  static double? _parseLoad(String? load) {
    if (load == null || load.trim().isEmpty) return null;
    final match = RegExp(r'[-+]?[0-9]*\.?[0-9]+').firstMatch(load);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  static int _parseRestSeconds(String? rest) {
    if (rest == null || rest.trim().isEmpty) return 60;
    final match = RegExp(r'(\d+)').firstMatch(rest);
    if (match != null) return int.tryParse(match.group(1)!) ?? 60;
    return 60;
  }
}
