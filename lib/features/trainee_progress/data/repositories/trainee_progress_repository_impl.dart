import 'package:dartz/dartz.dart';
import 'package:guidr/core/error/failures.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';
import '../../domain/repositories/trainee_progress_repository.dart';
import '../datasources/trainee_progress_remote_data_source.dart';

class TraineeProgressRepositoryImpl implements TraineeProgressRepository {
  final TraineeProgressRemoteDataSource remoteDataSource;

  TraineeProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TraineeMeasurement>>> getMyMeasurements() async {
    try {
      final remoteData = await remoteDataSource.getMyMeasurements();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TraineeMeasurement>> addMeasurement(Map<String, dynamic> data) async {
    try {
      final remoteData = await remoteDataSource.addMeasurement(data);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TraineeProgressPicture>>> getMyProgressPictures() async {
    try {
      final remoteData = await remoteDataSource.getMyProgressPictures();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TraineeProgressPicture>> addProgressPicture(Map<String, dynamic> data) async {
    try {
      final remoteData = await remoteDataSource.addProgressPicture(data);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
