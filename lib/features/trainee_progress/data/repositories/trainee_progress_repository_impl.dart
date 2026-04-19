import 'package:dartz/dartz.dart';
import 'package:guidr/core/error/failures.dart';
import 'package:guidr/features/trainees/domain/entities/inbody_report.dart';
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
      return Right(await remoteDataSource.getMyMeasurements());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TraineeMeasurement>> addMeasurement(
      Map<String, dynamic> data) async {
    try {
      return Right(await remoteDataSource.addMeasurement(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TraineeProgressPicture>>> getMyProgressPictures() async {
    try {
      return Right(await remoteDataSource.getMyProgressPictures());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TraineeProgressPicture>> addProgressPicture(
      Map<String, dynamic> data) async {
    try {
      return Right(await remoteDataSource.addProgressPicture(data));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InBodyReport>>> getMyInBodyReports() async {
    try {
      return Right(await remoteDataSource.getMyInBodyReports());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TraineeProgressPicture>> uploadProgressPhoto({
    String? frontPath,
    String? sidePath,
    String? backPath,
    String? notes,
  }) async {
    try {
      return Right(await remoteDataSource.uploadProgressPhoto(
        frontPath: frontPath,
        sidePath: sidePath,
        backPath: backPath,
        notes: notes,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InBodyReport>> uploadInBodyReport({
    required String filePath,
    String? label,
  }) async {
    try {
      return Right(await remoteDataSource.uploadInBodyReport(
        filePath: filePath,
        label: label,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
