import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';
import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';
import 'workout_builder_event.dart';
import 'workout_builder_state.dart';

class WorkoutBuilderBloc
    extends Bloc<WorkoutBuilderEvent, WorkoutBuilderState> {
  final BuildersRepository buildersRepository;
  final TraineesRepository traineesRepository;

  WorkoutBuilderBloc({
    required this.buildersRepository,
    required this.traineesRepository,
  }) : super(WorkoutBuilderState.initial()) {
    on<WorkoutBuilderInit>(_onInit);
    on<SetStep>((event, emit) => emit(state.copyWith(currentStep: event.step)));
    on<FilterTrainees>(_onFilterTrainees);
    on<ToggleTrainee>(_onToggleTrainee);
    on<SelectAllTrainees>(_onSelectAllTrainees);
    on<UpdateWorkoutMetadata>(_onUpdateMetadata);
    on<ToggleSectionExpanded>(_onToggleSectionExpanded);
    on<AddExercise>(_onAddExercise);
    on<RemoveExercise>(_onRemoveExercise);
    on<UpdateExerciseDetails>(_onUpdateExerciseDetails);
    on<LoadLibraryExercises>(_onLoadLibrary);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<AssignWorkout>(_onAssignWorkout);
    on<SaveWorkoutTemplate>(_onSaveTemplate);
    on<SaveWorkoutDraft>(_onSaveDraft);
  }

  List<BuilderExercise> _listFor(BuilderSection s) => switch (s) {
        BuilderSection.warmUp => state.warmUp,
        BuilderSection.main => state.mainExercises,
        BuilderSection.coolDown => state.coolDown,
      };

  void _emitSection(
      BuilderSection s, List<BuilderExercise> list, Emitter<WorkoutBuilderState> emit) {
    emit(switch (s) {
      BuilderSection.warmUp => state.copyWith(warmUp: list),
      BuilderSection.main => state.copyWith(mainExercises: list),
      BuilderSection.coolDown => state.copyWith(coolDown: list),
    });
  }

  Future<void> _onInit(
      WorkoutBuilderInit event, Emitter<WorkoutBuilderState> emit) async {
    emit(state.copyWith(traineesLoading: true, clearError: true));
    try {
      final trainees = await traineesRepository.getMyTrainees();
      final active = trainees.where((t) => t.status == 'active').toList();
      emit(state.copyWith(
          traineesLoading: false,
          allTrainees: active,
          filteredTrainees: active));
    } catch (e) {
      emit(state.copyWith(traineesLoading: false, error: e.toString()));
    }
  }

  void _onFilterTrainees(
      FilterTrainees event, Emitter<WorkoutBuilderState> emit) {
    final q = event.query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? state.allTrainees
        : state.allTrainees.where((t) =>
            [t.name, t.email, t.goal]
                .any((f) => f.toLowerCase().contains(q))).toList();
    emit(state.copyWith(filteredTrainees: filtered));
  }

  void _onToggleTrainee(
      ToggleTrainee event, Emitter<WorkoutBuilderState> emit) {
    final updated = Set<int>.from(state.selectedTraineeIds);
    updated.contains(event.traineeId)
        ? updated.remove(event.traineeId)
        : updated.add(event.traineeId);
    emit(state.copyWith(selectedTraineeIds: updated));
  }

  void _onSelectAllTrainees(
      SelectAllTrainees event, Emitter<WorkoutBuilderState> emit) {
    final allIds = state.filteredTrainees.map((t) => t.id).toSet();
    emit(state.copyWith(
        selectedTraineeIds:
            state.selectedTraineeIds.length == allIds.length ? {} : allIds));
  }

  void _onUpdateMetadata(
      UpdateWorkoutMetadata event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(
      workoutName: event.name,
      difficulty: event.difficulty,
      instructions: event.instructions,
      caution: event.caution,
    ));
  }

  void _onToggleSectionExpanded(
      ToggleSectionExpanded event, Emitter<WorkoutBuilderState> emit) {
    emit(switch (event.section) {
      BuilderSection.warmUp =>
        state.copyWith(warmUpExpanded: !state.warmUpExpanded),
      BuilderSection.main =>
        state.copyWith(mainExpanded: !state.mainExpanded),
      BuilderSection.coolDown =>
        state.copyWith(coolDownExpanded: !state.coolDownExpanded),
    });
  }

  void _onAddExercise(AddExercise event, Emitter<WorkoutBuilderState> emit) {
    final list = List<BuilderExercise>.from(_listFor(event.section));
    final ex = event.libraryExercise != null
        ? BuilderExercise(
            exerciseId: event.libraryExercise!.id,
            name: event.libraryExercise!.name,
            sets: 3,
            reps: '10',
            rest: '60s',
            videoUrl: event.libraryExercise!.videoUrl)
        : BuilderExercise(name: event.customName ?? 'New Exercise');
    _emitSection(event.section, [...list, ex], emit);
  }

  void _onRemoveExercise(
      RemoveExercise event, Emitter<WorkoutBuilderState> emit) {
    final list = List<BuilderExercise>.from(_listFor(event.section));
    if (event.index >= 0 && event.index < list.length) {
      list.removeAt(event.index);
      _emitSection(event.section, list, emit);
    }
  }

  void _onUpdateExerciseDetails(
      UpdateExerciseDetails event, Emitter<WorkoutBuilderState> emit) {
    final list = List<BuilderExercise>.from(_listFor(event.section));
    if (event.index < 0 || event.index >= list.length) return;
    list[event.index] = list[event.index].copyWith(
      sets: event.sets,
      reps: event.reps,
      load: event.load,
      rest: event.rest,
      videoUrl: event.videoUrl,
    );
    _emitSection(event.section, list, emit);
  }

  Future<void> _onLoadLibrary(
      LoadLibraryExercises event, Emitter<WorkoutBuilderState> emit) async {
    if (state.libraryExercises.isNotEmpty) return;
    emit(state.copyWith(libraryLoading: true));
    try {
      final exercises = await buildersRepository.getExercises();
      emit(state.copyWith(libraryLoading: false, libraryExercises: exercises));
    } catch (e) {
      emit(state.copyWith(libraryLoading: false, error: e.toString()));
    }
  }

  void _onUpdateSchedule(
      UpdateSchedule event, Emitter<WorkoutBuilderState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      recurrence: event.recurrence,
      remindTrainee: event.remindTrainee,
      alertIfMissed: event.alertIfMissed,
    ));
  }

  Future<void> _onAssignWorkout(
      AssignWorkout event, Emitter<WorkoutBuilderState> emit) async {
    if (state.selectedTraineeIds.isEmpty) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final allExercises = [
        ...state.warmUp,
        ...state.mainExercises,
        ...state.coolDown,
      ];

      final exerciseIds = allExercises
          .where((ex) => ex.exerciseId != null)
          .map((ex) => ex.exerciseId!)
          .toList();

      final traineeIds = state.selectedTraineeIds.toList();

      final workout = <String, dynamic>{
        'name': state.workoutName.isEmpty ? 'Workout' : state.workoutName,
        'exerciseIds': exerciseIds,
      };
      if (state.caution.isNotEmpty) {
        workout['notes'] = state.caution;
      }

      final payload = <String, dynamic>{
        'title': state.workoutName.isEmpty
            ? 'Untitled workout'
            : state.workoutName,
        'traineeIds': traineeIds,
        'workouts': [workout],
      };
      if (state.instructions.isNotEmpty) {
        payload['description'] = state.instructions;
      }

      final plan = await buildersRepository.createExercisePlan(payload);
      await buildersRepository.assignExercisePlan(
        planId: plan.id,
        traineeIds: traineeIds,
      );
      emit(state.copyWith(saving: false, assignSuccess: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Map<String, dynamic> _buildPayload() {
    final allExercises = [
      ...state.warmUp,
      ...state.mainExercises,
      ...state.coolDown,
    ];

    final exerciseIds = allExercises
        .where((ex) => ex.exerciseId != null)
        .map((ex) => ex.exerciseId!)
        .toList();

    final workout = <String, dynamic>{
      'name': state.workoutName.isEmpty ? 'Workout' : state.workoutName,
      'exerciseIds': exerciseIds,
    };
    if (state.caution.isNotEmpty) {
      workout['notes'] = state.caution;
    }

    final payload = <String, dynamic>{
      'title': state.workoutName.isEmpty
          ? 'Untitled workout'
          : state.workoutName,
      'workouts': [workout],
    };
    if (state.instructions.isNotEmpty) {
      payload['description'] = state.instructions;
    }

    return payload;
  }

  Future<void> _onSaveTemplate(
      SaveWorkoutTemplate event, Emitter<WorkoutBuilderState> emit) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await buildersRepository.saveExercisePlanTemplate(_buildPayload());
      emit(state.copyWith(saving: false, templateSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> _onSaveDraft(
      SaveWorkoutDraft event, Emitter<WorkoutBuilderState> emit) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await buildersRepository.saveExercisePlanDraft(_buildPayload());
      emit(state.copyWith(saving: false, draftSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
