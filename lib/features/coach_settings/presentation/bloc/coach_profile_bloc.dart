import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coach_profile.dart';
import '../../domain/repositories/coach_repository.dart';

// Events
abstract class CoachProfileEvent extends Equatable {
  const CoachProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadCoachProfile extends CoachProfileEvent {}

class UpdateCoachProfile extends CoachProfileEvent {
  final String? fullName;
  final String? specialisation;
  final String? bio;

  const UpdateCoachProfile({this.fullName, this.specialisation, this.bio});

  @override
  List<Object?> get props => [fullName, specialisation, bio];
}

// States
abstract class CoachProfileState extends Equatable {
  const CoachProfileState();
  @override
  List<Object?> get props => [];
}

class CoachProfileInitial extends CoachProfileState {}

class CoachProfileLoading extends CoachProfileState {}

class CoachProfileLoaded extends CoachProfileState {
  final CoachProfile profile;
  const CoachProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CoachProfileError extends CoachProfileState {
  final String message;
  const CoachProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class CoachProfileBloc extends Bloc<CoachProfileEvent, CoachProfileState> {
  final CoachRepository repository;

  CoachProfileBloc({required this.repository}) : super(CoachProfileInitial()) {
    on<LoadCoachProfile>((event, emit) async {
      emit(CoachProfileLoading());
      try {
        final profile = await repository.getMyProfile();
        emit(CoachProfileLoaded(profile));
      } catch (e) {
        emit(CoachProfileError(e.toString()));
      }
    });

    on<UpdateCoachProfile>((event, emit) async {
      emit(CoachProfileLoading());
      try {
        final profile = await repository.updateMyProfile(
          fullName: event.fullName,
          specialisation: event.specialisation,
          bio: event.bio,
        );
        emit(CoachProfileLoaded(profile));
      } catch (e) {
        emit(CoachProfileError(e.toString()));
      }
    });
  }
}
