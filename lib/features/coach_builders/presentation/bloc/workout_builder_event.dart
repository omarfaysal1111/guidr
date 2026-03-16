import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'workout_builder_state.dart';

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
  final String? name;
  final String? difficulty;
  final String? instructions;
  final String? caution;
  const UpdateWorkoutMetadata({this.name, this.difficulty, this.instructions, this.caution});
}

class ToggleSectionExpanded extends WorkoutBuilderEvent {
  final BuilderSection section;
  const ToggleSectionExpanded(this.section);
}

class AddExercise extends WorkoutBuilderEvent {
  final BuilderSection section;
  final String? customName;
  final Exercise? libraryExercise;

  const AddExercise.custom(this.section, this.customName) : libraryExercise = null;
  const AddExercise.fromLibrary(this.section, this.libraryExercise) : customName = null;
}

class RemoveExercise extends WorkoutBuilderEvent {
  final BuilderSection section;
  final int index;
  const RemoveExercise(this.section, this.index);
}

class UpdateExerciseDetails extends WorkoutBuilderEvent {
  final BuilderSection section;
  final int index;
  final int? sets;
  final String? reps;
  final String? load;
  final String? rest;
  final String? videoUrl;

  const UpdateExerciseDetails({
    required this.section,
    required this.index,
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
  const UpdateSchedule({this.selectedDate, this.recurrence, this.remindTrainee, this.alertIfMissed});
}

class AssignWorkout extends WorkoutBuilderEvent {}

class SaveWorkoutTemplate extends WorkoutBuilderEvent {}

class SaveWorkoutDraft extends WorkoutBuilderEvent {}
