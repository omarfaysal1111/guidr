import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        emit(currentState.copyWith(traineeDetailLoading: true));
        try {
          final detail = await repository.getTraineeDetails(event.traineeId);
          emit(currentState.copyWith(
            traineeDetailLoading: false,
            traineeDetail: detail,
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
  }
}
