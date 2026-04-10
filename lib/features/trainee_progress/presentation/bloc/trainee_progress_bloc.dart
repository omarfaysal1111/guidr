import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/trainee_progress_repository.dart';
import '../../../../core/error/failures.dart';
import 'trainee_progress_event.dart';
import 'trainee_progress_state.dart';

class TraineeProgressBloc extends Bloc<TraineeProgressEvent, TraineeProgressState> {
  final TraineeProgressRepository repository;

  TraineeProgressBloc({required this.repository}) : super(TraineeProgressInitial()) {
    on<LoadTraineeProgress>(_onLoadTraineeProgress);
    on<AddMeasurement>(_onAddMeasurement);
    on<AddProgressPicture>(_onAddProgressPicture);
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
    final measurementsResult = await repository.getMyMeasurements();
    final picturesResult = await repository.getMyProgressPictures();

    measurementsResult.fold(
      (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to load measurements'))),
      (measurements) {
        picturesResult.fold(
          (failure) => emit(TraineeProgressError(message: _failureMessage(failure, 'Failed to load pictures'))),
          (pictures) {
            emit(TraineeProgressLoaded(measurements: measurements, pictures: pictures));
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
}
