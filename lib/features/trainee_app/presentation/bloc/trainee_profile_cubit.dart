import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trainee_app_profile.dart';
import '../../domain/repositories/trainee_app_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TraineeProfileState extends Equatable {
  const TraineeProfileState();

  @override
  List<Object?> get props => [];
}

class TraineeProfileInitial extends TraineeProfileState {}

class TraineeProfileLoading extends TraineeProfileState {}

class TraineeProfileLoaded extends TraineeProfileState {
  final TraineeAppProfile profile;

  const TraineeProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TraineeProfileError extends TraineeProfileState {
  final String message;

  const TraineeProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class TraineeProfileCubit extends Cubit<TraineeProfileState> {
  final TraineeAppRepository repository;

  TraineeProfileCubit({required this.repository}) : super(TraineeProfileInitial());

  Future<void> loadProfile() async {
    emit(TraineeProfileLoading());
    try {
      final profile = await repository.getMyProfile();
      emit(TraineeProfileLoaded(profile));
    } catch (e) {
      emit(TraineeProfileError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? fitnessGoal,
  }) async {
    emit(TraineeProfileLoading());
    try {
      final profile = await repository.updateMyProfile(
        fullName: fullName,
        fitnessGoal: fitnessGoal,
      );
      emit(TraineeProfileLoaded(profile));
    } catch (e) {
      emit(TraineeProfileError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
