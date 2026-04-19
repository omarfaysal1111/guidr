import 'package:equatable/equatable.dart';
import 'package:guidr/features/trainees/domain/entities/inbody_report.dart';
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
  final List<InBodyReport> inbodyReports;

  /// True while an upload is in flight — the UI stays visible but buttons are disabled.
  final bool isUploading;

  const TraineeProgressLoaded({
    required this.measurements,
    required this.pictures,
    this.inbodyReports = const [],
    this.isUploading = false,
  });

  TraineeProgressLoaded copyWith({
    List<TraineeMeasurement>? measurements,
    List<TraineeProgressPicture>? pictures,
    List<InBodyReport>? inbodyReports,
    bool? isUploading,
  }) {
    return TraineeProgressLoaded(
      measurements: measurements ?? this.measurements,
      pictures: pictures ?? this.pictures,
      inbodyReports: inbodyReports ?? this.inbodyReports,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [measurements, pictures, inbodyReports, isUploading];
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
