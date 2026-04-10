import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';

abstract class WorkoutBuilderEvent {
  const WorkoutBuilderEvent();
}

class WorkoutBuilderInit extends WorkoutBuilderEvent {}

class SetStep extends WorkoutBuilderEvent {
  final int step;
  const SetStep(this.step);
}

class FilterTrainees extends WorkoutBuilderEvent {
  final String query;
  const FilterTrainees(this.query);
}

class ToggleTrainee extends WorkoutBuilderEvent {
  final int traineeId;
  const ToggleTrainee(this.traineeId);
}

class SelectAllTrainees extends WorkoutBuilderEvent {}

class UpdateWorkoutMetadata extends WorkoutBuilderEvent {
  final String? planTitle;
  final String? difficulty;
  final String? instructions;
  final String? caution;
  const UpdateWorkoutMetadata({
    this.planTitle,
    this.difficulty,
    this.instructions,
    this.caution,
  });
}

class AddPlanSession extends WorkoutBuilderEvent {
  const AddPlanSession();
}

class RemovePlanSession extends WorkoutBuilderEvent {
  final int sessionIndex;
  const RemovePlanSession(this.sessionIndex);
}

class UpdateSessionTitle extends WorkoutBuilderEvent {
  final int sessionIndex;
  final String title;
  const UpdateSessionTitle(this.sessionIndex, this.title);
}

class ToggleSessionExpanded extends WorkoutBuilderEvent {
  final int sessionIndex;
  const ToggleSessionExpanded(this.sessionIndex);
}

class AddExerciseFromLibrary extends WorkoutBuilderEvent {
  final int sessionIndex;
  final Exercise libraryExercise;
  const AddExerciseFromLibrary(this.sessionIndex, this.libraryExercise);
}

class RemoveSessionExercise extends WorkoutBuilderEvent {
  final int sessionIndex;
  final int exerciseIndex;
  const RemoveSessionExercise(this.sessionIndex, this.exerciseIndex);
}

class UpdateSessionExerciseDetails extends WorkoutBuilderEvent {
  final int sessionIndex;
  final int exerciseIndex;
  final int? sets;
  final String? reps;
  final String? load;
  final String? rest;
  final String? videoUrl;

  const UpdateSessionExerciseDetails({
    required this.sessionIndex,
    required this.exerciseIndex,
    this.sets,
    this.reps,
    this.load,
    this.rest,
    this.videoUrl,
  });
}

class LoadLibraryExercises extends WorkoutBuilderEvent {}

class UpdateSchedule extends WorkoutBuilderEvent {
  final DateTime? selectedDate;
  final String? recurrence;
  final bool? remindTrainee;
  final bool? alertIfMissed;
  const UpdateSchedule({
    this.selectedDate,
    this.recurrence,
    this.remindTrainee,
    this.alertIfMissed,
  });
}

class AssignWorkout extends WorkoutBuilderEvent {}

class SaveWorkoutTemplate extends WorkoutBuilderEvent {}

class SaveWorkoutDraft extends WorkoutBuilderEvent {}
