import 'builder_exercise.dart';

/// One plan session (day) in the coach builder: title + library exercises.
class WorkoutPlanSessionDraft {
  final String title;
  final List<BuilderExercise> exercises;
  final bool expanded;

  const WorkoutPlanSessionDraft({
    this.title = '',
    this.exercises = const [],
    this.expanded = true,
  });

  WorkoutPlanSessionDraft copyWith({
    String? title,
    List<BuilderExercise>? exercises,
    bool? expanded,
  }) {
    return WorkoutPlanSessionDraft(
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      expanded: expanded ?? this.expanded,
    );
  }
}
