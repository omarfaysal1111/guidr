import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/error/failures.dart';
import 'package:guidr/features/trainees/domain/entities/inbody_report.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';
import '../../domain/repositories/trainee_progress_repository.dart';
import 'trainee_progress_event.dart';
import 'trainee_progress_state.dart';

class TraineeProgressBloc extends Bloc<TraineeProgressEvent, TraineeProgressState> {
  final TraineeProgressRepository repository;

  TraineeProgressBloc({required this.repository}) : super(TraineeProgressInitial()) {
    on<LoadTraineeProgress>(_onLoadTraineeProgress);
    on<AddMeasurement>(_onAddMeasurement);
    on<AddProgressPicture>(_onAddProgressPicture);
    on<UploadProgressPhoto>(_onUploadProgressPhoto);
    on<UploadInBodyReport>(_onUploadInBodyReport);
  }

  String _failureMessage(dynamic failure, String fallback) {
    if (failure is ServerFailure && failure.message != null) {
      return failure.message!;
    }
    return fallback;
  }

  Future<void> _onLoadTraineeProgress(
    LoadTraineeProgress event,
    Emitter<TraineeProgressState> emit,
  ) async {
    emit(TraineeProgressLoading());
    final results = await Future.wait([
      repository.getMyMeasurements(),
      repository.getMyProgressPictures(),
      repository.getMyInBodyReports(),
    ]);

    final measurementsResult = results[0] as Either<Failure, List<TraineeMeasurement>>;
    final picturesResult = results[1] as Either<Failure, List<TraineeProgressPicture>>;
    final inbodyResult = results[2] as Either<Failure, List<InBodyReport>>;

    measurementsResult.fold(
      (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to load measurements'))),
      (measurements) {
        picturesResult.fold(
          (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to load pictures'))),
          (pictures) {
            inbodyResult.fold(
              (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to load InBody reports'))),
              (inbodyReports) {
                emit(TraineeProgressLoaded(
                  measurements: measurements,
                  pictures: pictures,
                  inbodyReports: inbodyReports,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onAddMeasurement(
    AddMeasurement event,
    Emitter<TraineeProgressState> emit,
  ) async {
    emit(TraineeProgressLoading());
    final result = await repository.addMeasurement(event.data);
    result.fold(
      (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to add measurement'))),
      (_) {
        emit(const TraineeProgressActionSuccess(message: 'Measurement added successfully'));
        add(LoadTraineeProgress());
      },
    );
  }

  Future<void> _onAddProgressPicture(
    AddProgressPicture event,
    Emitter<TraineeProgressState> emit,
  ) async {
    emit(TraineeProgressLoading());
    final result = await repository.addProgressPicture(event.data);
    result.fold(
      (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to add progress picture'))),
      (_) {
        emit(const TraineeProgressActionSuccess(message: 'Progress picture added successfully'));
        add(LoadTraineeProgress());
      },
    );
  }

  Future<void> _onUploadProgressPhoto(
    UploadProgressPhoto event,
    Emitter<TraineeProgressState> emit,
  ) async {
    // Keep existing data visible but mark as uploading.
    final current = state is TraineeProgressLoaded
        ? (state as TraineeProgressLoaded).copyWith(isUploading: true)
        : null;
    if (current != null) {
      emit(current);
    } else {
      emit(TraineeProgressLoading());
    }

    final result = await repository.uploadProgressPhoto(
      frontPath: event.frontPath,
      sidePath: event.sidePath,
      backPath: event.backPath,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(TraineeProgressError(
          message: _failureMessage(failure, 'Failed to upload progress photo'))),
      (_) {
        emit(const TraineeProgressActionSuccess(message: 'Progress photo uploaded!'));
        add(LoadTraineeProgress());
      },
    );
  }

  Future<void> _onUploadInBodyReport(
    UploadInBodyReport event,
    Emitter<TraineeProgressState> emit,
  ) async {
    final current = state is TraineeProgressLoaded
        ? (state as TraineeProgressLoaded).copyWith(isUploading: true)
        : null;
    if (current != null) {
      emit(current);
    } else {
      emit(TraineeProgressLoading());
    }

    final result = await repository.uploadInBodyReport(
      filePath: event.filePath,
      label: event.label,
    );

    result.fold(
      (failure) => emit(TraineeProgressError(
          message: _failureMessage(failure, 'Failed to upload InBody report'))),
      (_) {
        emit(const TraineeProgressActionSuccess(message: 'InBody report uploaded!'));
        add(LoadTraineeProgress());
      },
    );
  }
}
