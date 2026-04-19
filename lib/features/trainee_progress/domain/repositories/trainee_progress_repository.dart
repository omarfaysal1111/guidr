import 'package:dartz/dartz.dart';
import 'package:guidr/core/error/failures.dart';
import 'package:guidr/features/trainees/domain/entities/inbody_report.dart';
import '../entities/trainee_measurement.dart';
import '../entities/trainee_progress_picture.dart';

abstract class TraineeProgressRepository {
  Future<Either<Failure, List<TraineeMeasurement>>> getMyMeasurements();
  Future<Either<Failure, TraineeMeasurement>> addMeasurement(Map<String, dynamic> data);
  Future<Either<Failure, List<TraineeProgressPicture>>> getMyProgressPictures();
  Future<Either<Failure, TraineeProgressPicture>> addProgressPicture(Map<String, dynamic> data);
  Future<Either<Failure, List<InBodyReport>>> getMyInBodyReports();
  Future<Either<Failure, TraineeProgressPicture>> uploadProgressPhoto({
    String? frontPath,
    String? sidePath,
    String? backPath,
    String? notes,
  });
  Future<Either<Failure, InBodyReport>> uploadInBodyReport({
    required String filePath,
    String? label,
  });
}
