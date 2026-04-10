import 'package:equatable/equatable.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';

abstract class TraineeProgressState extends Equatable {
  const TraineeProgressState();

  @override
  List<Object?> get props => [];
}

class TraineeProgressInitial extends TraineeProgressState {}

class TraineeProgressLoading extends TraineeProgressState {}

class TraineeProgressLoaded extends TraineeProgressState {
  final List<TraineeMeasurement> measurements;
  final List<TraineeProgressPicture> pictures;

  const TraineeProgressLoaded({
    required this.measurements,
    required this.pictures,
  });

  @override
  List<Object?> get props => [measurements, pictures];
}

class TraineeProgressError extends TraineeProgressState {
  final String message;

  const TraineeProgressError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TraineeProgressActionSuccess extends TraineeProgressState {
  final String message;

  const TraineeProgressActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
