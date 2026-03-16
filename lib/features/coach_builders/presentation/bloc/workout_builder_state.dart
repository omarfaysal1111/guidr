import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';

enum BuilderSection { warmUp, main, coolDown }

class WorkoutBuilderState {
  final int currentStep;
  final bool traineesLoading;
  final bool saving;
  final bool assignSuccess;
  final bool templateSaved;
  final bool draftSaved;
  final String? error;

  // Trainee data
  final List<Trainee> allTrainees;
  final List<Trainee> filteredTrainees;
  final Set<int> selectedTraineeIds;

  // Workout metadata
  final String workoutName;
  final String difficulty;
  final String instructions;
  final String caution;

  // Workout content
  final List<BuilderExercise> warmUp;
  final List<BuilderExercise> mainExercises;
  final List<BuilderExercise> coolDown;

  // UI expansion state
  final bool warmUpExpanded;
  final bool mainExpanded;
  final bool coolDownExpanded;

  // Library exercises
  final List<Exercise> libraryExercises;
  final bool libraryLoading;

  // Schedule
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
    required this.workoutName,
    required this.difficulty,
    required this.instructions,
    required this.caution,
    required this.warmUp,
    required this.mainExercises,
    required this.coolDown,
    required this.warmUpExpanded,
    required this.mainExpanded,
    required this.coolDownExpanded,
    required this.libraryExercises,
    required this.libraryLoading,
    required this.selectedDate,
    required this.recurrence,
    required this.remindTrainee,
    required this.alertIfMissed,
    this.error,
  });

  factory WorkoutBuilderState.initial() => const WorkoutBuilderState(
        currentStep: 1,
        allTrainees: [],
        filteredTrainees: [],
        selectedTraineeIds: {},
        traineesLoading: true,
        saving: false,
        assignSuccess: false,
        templateSaved: false,
        draftSaved: false,
        workoutName: '',
        difficulty: 'Easy',
        instructions: '',
        caution: '',
        warmUp: [BuilderExercise(name: 'Dynamic Warm-up')],
        mainExercises: [],
        coolDown: [],
        warmUpExpanded: true,
        mainExpanded: true,
        coolDownExpanded: false,
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
    String? workoutName,
    String? difficulty,
    String? instructions,
    String? caution,
    List<BuilderExercise>? warmUp,
    List<BuilderExercise>? mainExercises,
    List<BuilderExercise>? coolDown,
    bool? warmUpExpanded,
    bool? mainExpanded,
    bool? coolDownExpanded,
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
      workoutName: workoutName ?? this.workoutName,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      caution: caution ?? this.caution,
      warmUp: warmUp ?? this.warmUp,
      mainExercises: mainExercises ?? this.mainExercises,
      coolDown: coolDown ?? this.coolDown,
      warmUpExpanded: warmUpExpanded ?? this.warmUpExpanded,
      mainExpanded: mainExpanded ?? this.mainExpanded,
      coolDownExpanded: coolDownExpanded ?? this.coolDownExpanded,
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
