import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';
import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/workout_plan_session_draft.dart';
import 'package:guidr/features/coach_builders/domain/services/workout_plan_v1_line_builder.dart';
import 'package:guidr/features/coach_settings/domain/usecases/coach_data_use_case.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';
import 'workout_builder_event.dart';
import 'workout_builder_state.dart';

class WorkoutBuilderBloc
    extends Bloc<WorkoutBuilderEvent, WorkoutBuilderState> {
  final BuildersRepository buildersRepository;
  final TraineesRepository traineesRepository;
  final GetCoachDataUseCase getCoachDataUseCase;

  WorkoutBuilderBloc({
    required this.buildersRepository,
    required this.traineesRepository,
    required this.getCoachDataUseCase,
  }) : super(WorkoutBuilderState.initial()) {
    on<WorkoutBuilderInit>(_onInit);
    on<SetStep>((event, emit) => emit(state.copyWith(currentStep: event.step)));
    on<FilterTrainees>(_onFilterTrainees);
    on<ToggleTrainee>(_onToggleTrainee);
    on<SelectAllTrainees>(_onSelectAllTrainees);
    on<UpdateWorkoutMetadata>(_onUpdateMetadata);
    on<AddPlanSession>(_onAddPlanSession);
    on<RemovePlanSession>(_onRemovePlanSession);
    on<UpdateSessionTitle>(_onUpdateSessionTitle);
    on<ToggleSessionExpanded>(_onToggleSessionExpanded);
    on<AddExerciseFromLibrary>(_onAddExerciseFromLibrary);
    on<RemoveSessionExercise>(_onRemoveSessionExercise);
    on<UpdateSessionExerciseDetails>(_onUpdateSessionExerciseDetails);
    on<LoadLibraryExercises>(_onLoadLibrary);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<AssignWorkout>(_onAssignWorkout);
    on<SaveWorkoutTemplate>(_onSaveTemplate);
    on<SaveWorkoutDraft>(_onSaveDraft);
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
      planTitle: event.planTitle,
      difficulty: event.difficulty,
      instructions: event.instructions,
      caution: event.caution,
    ));
  }

  void _onAddPlanSession(AddPlanSession event, Emitter<WorkoutBuilderState> emit) {
    final next = List<WorkoutPlanSessionDraft>.from(state.sessions)
      ..add(const WorkoutPlanSessionDraft(
        title: '',
        exercises: [],
        expanded: true,
      ));
    emit(state.copyWith(sessions: next));
  }

  void _onRemovePlanSession(
      RemovePlanSession event, Emitter<WorkoutBuilderState> emit) {
    if (state.sessions.length <= 1) return;
    final i = event.sessionIndex;
    if (i < 0 || i >= state.sessions.length) return;
    final next = List<WorkoutPlanSessionDraft>.from(state.sessions)..removeAt(i);
    emit(state.copyWith(sessions: next));
  }

  void _onUpdateSessionTitle(
      UpdateSessionTitle event, Emitter<WorkoutBuilderState> emit) {
    _mutateSession(event.sessionIndex, (s) => s.copyWith(title: event.title),
        emit);
  }

  void _onToggleSessionExpanded(
      ToggleSessionExpanded event, Emitter<WorkoutBuilderState> emit) {
    final i = event.sessionIndex;
    if (i < 0 || i >= state.sessions.length) return;
    _mutateSession(i, (x) => x.copyWith(expanded: !x.expanded), emit);
  }

  void _mutateSession(
    int index,
    WorkoutPlanSessionDraft Function(WorkoutPlanSessionDraft) fn,
    Emitter<WorkoutBuilderState> emit,
  ) {
    if (index < 0 || index >= state.sessions.length) return;
    final next = List<WorkoutPlanSessionDraft>.from(state.sessions);
    next[index] = fn(next[index]);
    emit(state.copyWith(sessions: next));
  }

  void _onAddExerciseFromLibrary(
      AddExerciseFromLibrary event, Emitter<WorkoutBuilderState> emit) {
    final i = event.sessionIndex;
    if (i < 0 || i >= state.sessions.length) return;
    final session = state.sessions[i];
    final ex = BuilderExercise(
      exerciseId: event.libraryExercise.id,
      name: event.libraryExercise.name,
      sets: 3,
      reps: '10',
      rest: '60s',
      videoUrl: event.libraryExercise.videoUrl,
    );
    final exercises = List<BuilderExercise>.from(session.exercises)..add(ex);
    _mutateSession(i, (s) => s.copyWith(exercises: exercises), emit);
  }

  void _onRemoveSessionExercise(
      RemoveSessionExercise event, Emitter<WorkoutBuilderState> emit) {
    final i = event.sessionIndex;
    if (i < 0 || i >= state.sessions.length) return;
    final session = state.sessions[i];
    final list = List<BuilderExercise>.from(session.exercises);
    if (event.exerciseIndex < 0 || event.exerciseIndex >= list.length) return;
    list.removeAt(event.exerciseIndex);
    _mutateSession(i, (s) => s.copyWith(exercises: list), emit);
  }

  void _onUpdateSessionExerciseDetails(
      UpdateSessionExerciseDetails event, Emitter<WorkoutBuilderState> emit) {
    final i = event.sessionIndex;
    if (i < 0 || i >= state.sessions.length) return;
    final session = state.sessions[i];
    final list = List<BuilderExercise>.from(session.exercises);
    final j = event.exerciseIndex;
    if (j < 0 || j >= list.length) return;
    list[j] = list[j].copyWith(
      sets: event.sets,
      reps: event.reps,
      load: event.load,
      rest: event.rest,
      videoUrl: event.videoUrl,
    );
    _mutateSession(i, (s) => s.copyWith(exercises: list), emit);
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

  String _sessionLabel(int index, WorkoutPlanSessionDraft s) {
    final t = s.title.trim();
    if (t.isEmpty) return 'Session ${index + 1}';
    return t;
  }

  Future<void> _onAssignWorkout(
      AssignWorkout event, Emitter<WorkoutBuilderState> emit) async {
    if (state.selectedTraineeIds.isEmpty) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final coach = await getCoachDataUseCase();
      final coachId = coach.userId ?? int.tryParse(coach.id);
      if (coachId == null || coachId == 0) {
        emit(state.copyWith(
          saving: false,
          error: 'Could not resolve coach id for this account.',
        ));
        return;
      }

      final planTitle = state.planTitle.trim().isEmpty
          ? 'Workout plan'
          : state.planTitle.trim();

      for (var i = 0; i < state.sessions.length; i++) {
        final session = state.sessions[i];
        if (session.exercises.isEmpty) {
          emit(state.copyWith(
            saving: false,
            error:
                '${_sessionLabel(i, session)} has no exercises. Add library exercises or remove the session.',
          ));
          return;
        }
        final v = WorkoutPlanV1LineBuilder.validateSessionCatalog(
          session.exercises,
          _sessionLabel(i, session),
        );
        if (v != null) {
          emit(state.copyWith(saving: false, error: v));
          return;
        }
      }

      final description = state.instructions.trim().isEmpty
          ? (state.caution.trim().isEmpty ? null : state.caution.trim())
          : state.instructions.trim();

      final plan = await buildersRepository.createWorkoutPlanV1(
        title: planTitle,
        description: description,
        coachId: coachId,
      );

      for (var i = 0; i < state.sessions.length; i++) {
        final session = state.sessions[i];
        final sessionTitle = _sessionLabel(i, session);
        final created = await buildersRepository.createPlanSessionV1(
          planId: plan.id,
          title: sessionTitle,
          dayOrder: i,
        );
        final lines =
            WorkoutPlanV1LineBuilder.buildMainLines(session.exercises);
        await buildersRepository.replacePlanSessionExercisesV1(
          planSessionId: created.planSessionId,
          lines: lines,
        );
      }

      final traineeIds = state.selectedTraineeIds.toList();
      final startDate = _formatPlanStartDate(state.selectedDate);
      final assignErrors = <String>[];
      for (final tid in traineeIds) {
        try {
          await buildersRepository.assignWorkoutPlanV1(
            planId: plan.id,
            traineeId: tid,
            startDate: startDate,
          );
        } catch (e) {
          assignErrors.add(e.toString());
        }
      }

      if (assignErrors.isEmpty) {
        emit(state.copyWith(saving: false, assignSuccess: true));
      } else if (assignErrors.length == traineeIds.length) {
        emit(state.copyWith(
          saving: false,
          error: assignErrors.join('\n'),
        ));
      } else {
        emit(state.copyWith(
          saving: false,
          error:
              'Plan saved, but some assignments failed:\n${assignErrors.join('\n')}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  static String _formatPlanStartDate(DateTime? selected) {
    final d = selected ?? DateTime.now();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> _buildPayload() {
    final workouts = <Map<String, dynamic>>[];
    for (var i = 0; i < state.sessions.length; i++) {
      final s = state.sessions[i];
      final exerciseIds = s.exercises
          .where((ex) => ex.exerciseId != null)
          .map((ex) => ex.exerciseId!)
          .toList();
      final name = s.title.trim().isEmpty ? 'Session ${i + 1}' : s.title.trim();
      final w = <String, dynamic>{
        'name': name,
        'exerciseIds': exerciseIds,
      };
      if (state.caution.isNotEmpty) {
        w['notes'] = state.caution;
      }
      workouts.add(w);
    }

    final payload = <String, dynamic>{
      'title': state.planTitle.isEmpty ? 'Untitled plan' : state.planTitle,
      'workouts': workouts,
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
