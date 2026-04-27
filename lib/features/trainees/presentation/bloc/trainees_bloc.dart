import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/trainee_app/domain/entities/water_intake_day.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/trainee.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import '../../domain/repositories/trainees_repository.dart';

// Events
abstract class TraineesEvent extends Equatable {
  const TraineesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTraineesEvent extends TraineesEvent {}

class FilterTraineesEvent extends TraineesEvent {
  final String filter; // 'all', 'active', 'attention', 'pending', 'inactive'
  final String searchQuery;

  const FilterTraineesEvent({this.filter = 'all', this.searchQuery = ''});

  @override
  List<Object?> get props => [filter, searchQuery];
}

class ToggleBulkModeEvent extends TraineesEvent {
  final bool isBulkMode;

  const ToggleBulkModeEvent(this.isBulkMode);

  @override
  List<Object?> get props => [isBulkMode];
}

class ToggleSelectTraineeEvent extends TraineesEvent {
  final int traineeId;

  const ToggleSelectTraineeEvent(this.traineeId);

  @override
  List<Object?> get props => [traineeId];
}

class InviteTraineeEvent extends TraineesEvent {
  final String email;

  const InviteTraineeEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ClearInviteResultEvent extends TraineesEvent {}

class LoadTraineeDetailEvent extends TraineesEvent {
  final String traineeId;

  const LoadTraineeDetailEvent(this.traineeId);

  @override
  List<Object?> get props => [traineeId];
}

class UpdateTraineeGoalLevelEvent extends TraineesEvent {
  final String traineeId;
  final String goal;
  final String level;

  const UpdateTraineeGoalLevelEvent({
    required this.traineeId,
    required this.goal,
    required this.level,
  });

  @override
  List<Object?> get props => [traineeId, goal, level];
}

class SaveCoachNotesEvent extends TraineesEvent {
  final String traineeId;
  final String feedback;
  final String caution;

  const SaveCoachNotesEvent({
    required this.traineeId,
    required this.feedback,
    required this.caution,
  });

  @override
  List<Object?> get props => [traineeId, feedback, caution];
}

class AddGoalEvent extends TraineesEvent {
  final String traineeId;
  final String title;

  const AddGoalEvent({required this.traineeId, required this.title});

  @override
  List<Object?> get props => [traineeId, title];
}

class ToggleGoalEvent extends TraineesEvent {
  final String traineeId;
  final String goalId;
  final bool completed;

  const ToggleGoalEvent({
    required this.traineeId,
    required this.goalId,
    required this.completed,
  });

  @override
  List<Object?> get props => [traineeId, goalId, completed];
}

class DeleteGoalEvent extends TraineesEvent {
  final String traineeId;
  final String goalId;

  const DeleteGoalEvent({required this.traineeId, required this.goalId});

  @override
  List<Object?> get props => [traineeId, goalId];
}

class EditGoalEvent extends TraineesEvent {
  final String traineeId;
  final String goalId;
  final String newTitle;

  const EditGoalEvent({
    required this.traineeId,
    required this.goalId,
    required this.newTitle,
  });

  @override
  List<Object?> get props => [traineeId, goalId, newTitle];
}

class UploadInBodyReportEvent extends TraineesEvent {
  final String traineeId;
  final List<int> fileBytes;
  final String fileName;

  const UploadInBodyReportEvent({
    required this.traineeId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [traineeId, fileName, fileBytes.length];
}

class UploadProgressPhotoEvent extends TraineesEvent {
  final String traineeId;
  final List<int> fileBytes;
  final String fileName;

  const UploadProgressPhotoEvent({
    required this.traineeId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [traineeId, fileName, fileBytes.length];
}

class ArchiveTraineeEvent extends TraineesEvent {
  final String traineeId;
  const ArchiveTraineeEvent(this.traineeId);
  @override
  List<Object?> get props => [traineeId];
}

class DeleteTraineeEvent extends TraineesEvent {
  final String traineeId;
  const DeleteTraineeEvent(this.traineeId);
  @override
  List<Object?> get props => [traineeId];
}

enum TraineeSortField { name, adherence, streak }

class SortTraineesEvent extends TraineesEvent {
  final TraineeSortField field;
  final bool ascending;
  const SortTraineesEvent({required this.field, this.ascending = true});
  @override
  List<Object?> get props => [field, ascending];
}

// States
abstract class TraineesState extends Equatable {
  const TraineesState();
  
  @override
  List<Object?> get props => [];
}

class TraineesInitial extends TraineesState {}

class TraineesLoading extends TraineesState {}

class TraineesLoaded extends TraineesState {
  final List<Trainee> allTrainees;
  final List<Trainee> filteredTrainees;
  final String activeFilter;
  final String searchQuery;
  final bool isBulkMode;
  final List<int> selectedIds;
  final bool invitationLoading;
  final Invitation? invitationResult;
  final String? invitationError;
  final CoachTraineeDetail? traineeDetail;
  final bool traineeDetailLoading;
  final bool goalLevelSaving;
  final String? goalLevelError;
  final bool coachNotesSaving;
  final String? coachNotesError;
  final bool goalsSaving;
  final String? goalsError;
  final bool inbodyUploadSaving;
  final String? inbodyUploadError;
  final bool progressPhotoUploadSaving;
  final String? progressPhotoUploadError;
  final WaterIntakeDay? traineeWaterIntake;

  const TraineesLoaded({
    required this.allTrainees,
    required this.filteredTrainees,
    required this.activeFilter,
    required this.searchQuery,
    required this.isBulkMode,
    required this.selectedIds,
    this.invitationLoading = false,
    this.invitationResult,
    this.invitationError,
    this.traineeDetail,
    this.traineeDetailLoading = false,
    this.goalLevelSaving = false,
    this.goalLevelError,
    this.coachNotesSaving = false,
    this.coachNotesError,
    this.goalsSaving = false,
    this.goalsError,
    this.inbodyUploadSaving = false,
    this.inbodyUploadError,
    this.progressPhotoUploadSaving = false,
    this.progressPhotoUploadError,
    this.traineeWaterIntake,
  });

  TraineesLoaded copyWith({
    List<Trainee>? allTrainees,
    List<Trainee>? filteredTrainees,
    String? activeFilter,
    String? searchQuery,
    bool? isBulkMode,
    List<int>? selectedIds,
    bool? invitationLoading,
    Invitation? invitationResult,
    String? invitationError,
    bool clearInviteResult = false,
    bool clearInvitationError = false,
    CoachTraineeDetail? traineeDetail,
    bool? traineeDetailLoading,
    bool? goalLevelSaving,
    String? goalLevelError,
    bool clearGoalLevelError = false,
    bool? coachNotesSaving,
    String? coachNotesError,
    bool clearCoachNotesError = false,
    bool? goalsSaving,
    String? goalsError,
    bool clearGoalsError = false,
    bool? inbodyUploadSaving,
    String? inbodyUploadError,
    bool clearInbodyUploadError = false,
    bool? progressPhotoUploadSaving,
    String? progressPhotoUploadError,
    bool clearProgressPhotoUploadError = false,
    WaterIntakeDay? traineeWaterIntake,
    bool clearTraineeWaterIntake = false,
  }) {
    return TraineesLoaded(
      allTrainees: allTrainees ?? this.allTrainees,
      filteredTrainees: filteredTrainees ?? this.filteredTrainees,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isBulkMode: isBulkMode ?? this.isBulkMode,
      selectedIds: selectedIds ?? this.selectedIds,
      invitationLoading: invitationLoading ?? this.invitationLoading,
      invitationResult: clearInviteResult ? null : (invitationResult ?? this.invitationResult),
      invitationError: clearInviteResult || clearInvitationError
          ? null
          : (invitationError ?? this.invitationError),
      traineeDetail: traineeDetail ?? this.traineeDetail,
      traineeDetailLoading: traineeDetailLoading ?? this.traineeDetailLoading,
      goalLevelSaving: goalLevelSaving ?? this.goalLevelSaving,
      goalLevelError: clearGoalLevelError ? null : (goalLevelError ?? this.goalLevelError),
      coachNotesSaving: coachNotesSaving ?? this.coachNotesSaving,
      coachNotesError: clearCoachNotesError ? null : (coachNotesError ?? this.coachNotesError),
      goalsSaving: goalsSaving ?? this.goalsSaving,
      goalsError: clearGoalsError ? null : (goalsError ?? this.goalsError),
      inbodyUploadSaving: inbodyUploadSaving ?? this.inbodyUploadSaving,
      inbodyUploadError: clearInbodyUploadError
          ? null
          : (inbodyUploadError ?? this.inbodyUploadError),
      progressPhotoUploadSaving: progressPhotoUploadSaving ?? this.progressPhotoUploadSaving,
      progressPhotoUploadError: clearProgressPhotoUploadError
          ? null
          : (progressPhotoUploadError ?? this.progressPhotoUploadError),
      traineeWaterIntake: clearTraineeWaterIntake
          ? null
          : (traineeWaterIntake ?? this.traineeWaterIntake),
    );
  }

  @override
  List<Object?> get props => [
        allTrainees,
        filteredTrainees,
        activeFilter,
        searchQuery,
        isBulkMode,
        selectedIds,
        invitationLoading,
        invitationResult,
        invitationError,
        traineeDetail,
        traineeDetailLoading,
        goalLevelSaving,
        goalLevelError,
        coachNotesSaving,
        coachNotesError,
        goalsSaving,
        goalsError,
        inbodyUploadSaving,
        inbodyUploadError,
        progressPhotoUploadSaving,
        progressPhotoUploadError,
        traineeWaterIntake,
      ];
}

// BLoC
class TraineesBloc extends Bloc<TraineesEvent, TraineesState> {
  final TraineesRepository repository;

  TraineesBloc({required this.repository}) : super(TraineesInitial()) {
    on<LoadTraineesEvent>((event, emit) async {
      emit(TraineesLoading());
      try {
        final trainees = await repository.getMyTrainees();
        emit(TraineesLoaded(
          allTrainees: trainees,
          filteredTrainees: trainees,
          activeFilter: 'all',
          searchQuery: '',
          isBulkMode: false,
          selectedIds: const [],
          traineeDetailLoading: false,
        ));
      } catch (e) {
        // Fallback to empty list or handle error if needed
        emit(const TraineesLoaded(
          allTrainees: [],
          filteredTrainees: [],
          activeFilter: 'all',
          searchQuery: '',
          isBulkMode: false,
          selectedIds: [],
          traineeDetailLoading: false,
        ));
      }
    });

    on<LoadTraineeDetailEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(
          traineeDetailLoading: true,
          clearTraineeWaterIntake: true,
        ));
        try {
          final detail = await repository.getTraineeDetails(event.traineeId);
          WaterIntakeDay? water;
          try {
            water = await repository.getTraineeWaterIntake(event.traineeId);
          } catch (_) {
            water = null;
          }
          emit(currentState.copyWith(
            traineeDetailLoading: false,
            traineeDetail: detail,
            traineeWaterIntake: water,
            clearTraineeWaterIntake: false,
          ));
        } catch (e) {
          emit(currentState.copyWith(traineeDetailLoading: false));
        }
      }
    });

    on<FilterTraineesEvent>((event, emit) {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        
        final filteredList = currentState.allTrainees.where((t) {
          // Status filter
          bool matchesFilter = true;
          if (event.filter == 'active') matchesFilter = t.status == 'active';
          if (event.filter == 'attention') matchesFilter = t.alerts.isNotEmpty;
          if (event.filter == 'pending') matchesFilter = t.status == 'pending';
          if (event.filter == 'inactive') matchesFilter = t.status == 'inactive';

          // Search filter
          bool matchesSearch = true;
          if (event.searchQuery.isNotEmpty) {
            final q = event.searchQuery.toLowerCase();
            matchesSearch = t.name.toLowerCase().contains(q) || 
                            t.email.toLowerCase().contains(q) || 
                            t.goal.toLowerCase().contains(q);
          }

          return matchesFilter && matchesSearch;
        }).toList();

        emit(currentState.copyWith(
          filteredTrainees: filteredList,
          activeFilter: event.filter,
          searchQuery: event.searchQuery,
        ));
      }
    });

    on<ToggleBulkModeEvent>((event, emit) {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(
          isBulkMode: event.isBulkMode,
          selectedIds: event.isBulkMode ? currentState.selectedIds : [],
        ));
      }
    });

    on<ToggleSelectTraineeEvent>((event, emit) {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        final selectedIds = List<int>.from(currentState.selectedIds);
        if (selectedIds.contains(event.traineeId)) {
          selectedIds.remove(event.traineeId);
        } else {
          selectedIds.add(event.traineeId);
        }
        emit(currentState.copyWith(selectedIds: selectedIds));
      }
    });

    on<InviteTraineeEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(
          invitationLoading: true,
          clearInviteResult: true,
        ));
        try {
          final invitation = await repository.createInvitation(event.email);
          emit(currentState.copyWith(
            invitationLoading: false,
            invitationResult: invitation,
            clearInvitationError: true,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            invitationLoading: false,
            invitationError: e.toString().replaceFirst('Exception: ', ''),
            clearInviteResult: false,
          ));
        }
      }
    });

    on<ClearInviteResultEvent>((event, emit) {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(clearInviteResult: true));
      }
    });

    on<UpdateTraineeGoalLevelEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(goalLevelSaving: true, clearGoalLevelError: true));
        try {
          await repository.updateTraineeGoalLevel(event.traineeId, event.goal, event.level);
          // Reload trainee details so the UI reflects the saved values.
          final updated = await repository.getTraineeDetails(event.traineeId);
          emit(currentState.copyWith(
            goalLevelSaving: false,
            traineeDetail: updated,
            clearGoalLevelError: true,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            goalLevelSaving: false,
            goalLevelError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<SaveCoachNotesEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(coachNotesSaving: true, clearCoachNotesError: true));
        try {
          await repository.saveCoachNotes(event.traineeId, event.feedback, event.caution);
          final updated = await repository.getTraineeDetails(event.traineeId);
          emit(currentState.copyWith(
            coachNotesSaving: false,
            traineeDetail: updated,
            clearCoachNotesError: true,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            coachNotesSaving: false,
            coachNotesError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<AddGoalEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        await _runGoalsMutation(
          state as TraineesLoaded,
          emit,
          event.traineeId,
          () => repository.addGoal(event.traineeId, event.title),
        );
      }
    });

    on<ToggleGoalEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        await _runGoalsMutation(
          state as TraineesLoaded,
          emit,
          event.traineeId,
          () => repository.toggleGoal(event.traineeId, event.goalId, event.completed),
        );
      }
    });

    on<DeleteGoalEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        await _runGoalsMutation(
          state as TraineesLoaded,
          emit,
          event.traineeId,
          () => repository.deleteGoal(event.traineeId, event.goalId),
        );
      }
    });

    on<EditGoalEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        await _runGoalsMutation(
          state as TraineesLoaded,
          emit,
          event.traineeId,
          () => repository.editGoal(event.goalId, event.newTitle),
        );
      }
    });

    on<UploadInBodyReportEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(inbodyUploadSaving: true, clearInbodyUploadError: true));
        try {
          await repository.uploadInBodyReport(
            event.traineeId,
            event.fileBytes,
            event.fileName,
          );
          final updated = await repository.getTraineeDetails(event.traineeId);
          emit(currentState.copyWith(
            inbodyUploadSaving: false,
            traineeDetail: updated,
            clearInbodyUploadError: true,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            inbodyUploadSaving: false,
            inbodyUploadError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<UploadProgressPhotoEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        emit(currentState.copyWith(
          progressPhotoUploadSaving: true,
          clearProgressPhotoUploadError: true,
        ));
        try {
          await repository.uploadProgressPhoto(
            event.traineeId,
            event.fileBytes,
            event.fileName,
          );
          final updated = await repository.getTraineeDetails(event.traineeId);
          emit(currentState.copyWith(
            progressPhotoUploadSaving: false,
            traineeDetail: updated,
            clearProgressPhotoUploadError: true,
          ));
        } catch (e) {
          emit(currentState.copyWith(
            progressPhotoUploadSaving: false,
            progressPhotoUploadError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<ArchiveTraineeEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        try {
          await repository.archiveTrainee(event.traineeId);
          final trainees = await repository.getMyTrainees();
          emit(TraineesLoaded(
            allTrainees: trainees,
            filteredTrainees: trainees,
            activeFilter: 'all',
            searchQuery: '',
            isBulkMode: false,
            selectedIds: const [],
          ));
        } catch (e) {
          emit(currentState.copyWith(
            goalsError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<DeleteTraineeEvent>((event, emit) async {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        try {
          await repository.deleteTrainee(event.traineeId);
          final trainees = await repository.getMyTrainees();
          emit(TraineesLoaded(
            allTrainees: trainees,
            filteredTrainees: trainees,
            activeFilter: 'all',
            searchQuery: '',
            isBulkMode: false,
            selectedIds: const [],
          ));
        } catch (e) {
          emit(currentState.copyWith(
            goalsError: e.toString().replaceFirst('Exception: ', ''),
          ));
        }
      }
    });

    on<SortTraineesEvent>((event, emit) {
      if (state is TraineesLoaded) {
        final currentState = state as TraineesLoaded;
        final sorted = List<Trainee>.from(currentState.filteredTrainees);
        sorted.sort((a, b) {
          int cmp;
          switch (event.field) {
            case TraineeSortField.name:
              cmp = a.name.compareTo(b.name);
            case TraineeSortField.adherence:
              cmp = a.adherence.compareTo(b.adherence);
            case TraineeSortField.streak:
              cmp = a.currentStreak.compareTo(b.currentStreak);
          }
          return event.ascending ? cmp : -cmp;
        });
        emit(currentState.copyWith(filteredTrainees: sorted));
      }
    });
  }

  Future<void> _runGoalsMutation(
    TraineesLoaded currentState,
    Emitter<TraineesState> emit,
    String traineeId,
    Future<void> Function() request,
  ) async {
    emit(currentState.copyWith(goalsSaving: true, clearGoalsError: true));
    try {
      await request();
      final updated = await repository.getTraineeDetails(traineeId);
      emit(currentState.copyWith(
        goalsSaving: false,
        traineeDetail: updated,
        clearGoalsError: true,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        goalsSaving: false,
        goalsError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
