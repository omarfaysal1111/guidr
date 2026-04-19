import 'package:equatable/equatable.dart';

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

/// Upload one or more progress photos (front / side / back) from local file paths.
class UploadProgressPhoto extends TraineeProgressEvent {
  final String? frontPath;
  final String? sidePath;
  final String? backPath;
  final String? notes;

  const UploadProgressPhoto({
    this.frontPath,
    this.sidePath,
    this.backPath,
    this.notes,
  });

  @override
  List<Object?> get props => [frontPath, sidePath, backPath, notes];
}

/// Upload a single InBody report (PDF or image) from a local file path.
class UploadInBodyReport extends TraineeProgressEvent {
  final String filePath;
  final String? label;

  const UploadInBodyReport({required this.filePath, this.label});

  @override
  List<Object?> get props => [filePath, label];
}
