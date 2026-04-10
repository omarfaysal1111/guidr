import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/workout_plan_session_draft.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';

class WorkoutBuilderState {
  final int currentStep;
  final bool traineesLoading;
  final bool saving;
  final bool assignSuccess;
  final bool templateSaved;
  final bool draftSaved;
  final String? error;

  final List<Trainee> allTrainees;
  final List<Trainee> filteredTrainees;
  final Set<int> selectedTraineeIds;

  /// Top-level plan name (v1 `POST /v1/plans` title).
  final String planTitle;
  final String difficulty;
  final String instructions;
  final String caution;

  final List<WorkoutPlanSessionDraft> sessions;

  final List<Exercise> libraryExercises;
  final bool libraryLoading;

  final DateTime? selectedDate;
  final String recurrence;
  final bool remindTrainee;
  final bool alertIfMissed;

  const WorkoutBuilderState({
    required this.currentStep,
    required this.allTrainees,
    required this.filteredTrainees,
    required this.selectedTraineeIds,
    required this.traineesLoading,
    required this.saving,
    required this.assignSuccess,
    required this.templateSaved,
    required this.draftSaved,
    required this.planTitle,
    required this.difficulty,
    required this.instructions,
    required this.caution,
    required this.sessions,
    required this.libraryExercises,
    required this.libraryLoading,
    required this.selectedDate,
    required this.recurrence,
    required this.remindTrainee,
    required this.alertIfMissed,
    this.error,
  });

  int get totalExerciseCount =>
      sessions.fold(0, (sum, s) => sum + s.exercises.length);

  factory WorkoutBuilderState.initial() => WorkoutBuilderState(
        currentStep: 1,
        allTrainees: [],
        filteredTrainees: [],
        selectedTraineeIds: {},
        traineesLoading: true,
        saving: false,
        assignSuccess: false,
        templateSaved: false,
        draftSaved: false,
        planTitle: '',
        difficulty: 'Easy',
        instructions: '',
        caution: '',
        sessions: const [
          WorkoutPlanSessionDraft(title: '', exercises: [], expanded: true),
        ],
        libraryExercises: [],
        libraryLoading: false,
        selectedDate: null,
        recurrence: 'One-time',
        remindTrainee: true,
        alertIfMissed: true,
        error: null,
      );

  WorkoutBuilderState copyWith({
    int? currentStep,
    List<Trainee>? allTrainees,
    List<Trainee>? filteredTrainees,
    Set<int>? selectedTraineeIds,
    bool? traineesLoading,
    bool? saving,
    bool? assignSuccess,
    bool? templateSaved,
    bool? draftSaved,
    String? planTitle,
    String? difficulty,
    String? instructions,
    String? caution,
    List<WorkoutPlanSessionDraft>? sessions,
    List<Exercise>? libraryExercises,
    bool? libraryLoading,
    DateTime? selectedDate,
    String? recurrence,
    bool? remindTrainee,
    bool? alertIfMissed,
    String? error,
    bool clearError = false,
  }) {
    return WorkoutBuilderState(
      currentStep: currentStep ?? this.currentStep,
      allTrainees: allTrainees ?? this.allTrainees,
      filteredTrainees: filteredTrainees ?? this.filteredTrainees,
      selectedTraineeIds: selectedTraineeIds ?? this.selectedTraineeIds,
      traineesLoading: traineesLoading ?? this.traineesLoading,
      saving: saving ?? this.saving,
      assignSuccess: assignSuccess ?? this.assignSuccess,
      templateSaved: templateSaved ?? this.templateSaved,
      draftSaved: draftSaved ?? this.draftSaved,
      planTitle: planTitle ?? this.planTitle,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      caution: caution ?? this.caution,
      sessions: sessions ?? this.sessions,
      libraryExercises: libraryExercises ?? this.libraryExercises,
      libraryLoading: libraryLoading ?? this.libraryLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      recurrence: recurrence ?? this.recurrence,
      remindTrainee: remindTrainee ?? this.remindTrainee,
      alertIfMissed: alertIfMissed ?? this.alertIfMissed,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
