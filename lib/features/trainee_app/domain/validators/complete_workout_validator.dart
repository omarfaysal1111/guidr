import '../entities/complete_workout_request.dart';

class CompleteWorkoutValidator {
  /// Returns an error message or null if valid.
  static String? validate({
    required CompleteWorkoutRequest request,
    required Map<String, int> plannedSetsByExerciseLineId,
  }) {
    for (final item in request.exerciseLogs) {
      final id = item.planSessionExerciseId.trim();
      if (id.isEmpty) {
        return 'Missing plan session exercise id.';
      }

      final planned = plannedSetsByExerciseLineId[id];
      if (planned == null) {
        return 'Unknown exercise line: $id';
      }

      final outcomes = item.setOutcomes;
      if (outcomes != null && outcomes.isNotEmpty) {
        // // final hasLegacy = item.actualSetsCompleted != null ||
        // //     item.skippedSets != null ||
        // //     (item.excuse != null && item.excuse!.trim().isNotEmpty);
        // if (hasLegacy) {
        //   return 'Do not mix setOutcomes with legacy fields on the same exercise.';
        // }
        // if (outcomes.length != planned) {
        //   return 'Exercise $id: expected $planned set outcome(s), got ${outcomes.length}.';
        // }
        for (var i = 0; i < outcomes.length; i++) {
          final o = outcomes[i];
          if (o.outcome == SetLogOutcome.skipped ||
              o.outcome == SetLogOutcome.missed) {
            if (o.reason == null || o.reason!.trim().isEmpty) {
              final label = switch (o.outcome) {
                SetLogOutcome.skipped => 'SKIPPED',
                SetLogOutcome.missed => 'MISSED',
                SetLogOutcome.completed => 'COMPLETED',
              };
              return 'Set ${i + 1} ($id): reason is required for $label.';
            }
          }
        }
      } else {
        // final a = item.actualSetsCompleted;
        // final s = item.skippedSets;
        // if (a == null || s == null) {
        //   return 'Exercise $id: send setOutcomes or legacy completion fields.';
        // }
        // if (a + s != planned) {
        //   return 'Exercise $id: actualSetsCompleted + skippedSets must equal $planned.';
        // }
        // if (s > 0 &&
        //     (item.excuse == null || item.excuse!.trim().isEmpty)) {
        //   return 'Exercise $id: excuse is required when skippedSets > 0.';
        // }
      }
    }
    return null;
  }
}
