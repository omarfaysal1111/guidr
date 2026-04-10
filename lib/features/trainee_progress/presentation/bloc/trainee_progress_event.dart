import 'package:equatable/equatable.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';

abstract class TraineeProgressEvent extends Equatable {
  const TraineeProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadTraineeProgress extends TraineeProgressEvent {}

class AddMeasurement extends TraineeProgressEvent {
  final Map<String, dynamic> data;

  const AddMeasurement(this.data);

  @override
  List<Object?> get props => [data];
}

class AddProgressPicture extends TraineeProgressEvent {
  final Map<String, dynamic> data;

  const AddProgressPicture(this.data);

  @override
  List<Object?> get props => [data];
}
