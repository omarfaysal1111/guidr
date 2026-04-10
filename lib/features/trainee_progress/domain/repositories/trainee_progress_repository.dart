import 'package:dartz/dartz.dart';
import 'package:guidr/core/error/failures.dart';
import '../entities/trainee_measurement.dart';
import '../entities/trainee_progress_picture.dart';

abstract class TraineeProgressRepository {
  Future<Either<Failure, List<TraineeMeasurement>>> getMyMeasurements();
  Future<Either<Failure, TraineeMeasurement>> addMeasurement(Map<String, dynamic> data);
  Future<Either<Failure, List<TraineeProgressPicture>>> getMyProgressPictures();
  Future<Either<Failure, TraineeProgressPicture>> addProgressPicture(Map<String, dynamic> data);
}
