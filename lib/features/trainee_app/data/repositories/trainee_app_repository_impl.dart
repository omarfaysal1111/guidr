import '../../domain/entities/trainee_app_profile.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';
import '../../domain/repositories/trainee_app_repository.dart';
import '../datasources/trainee_app_remote_data_source.dart';

class TraineeAppRepositoryImpl implements TraineeAppRepository {
  final TraineeAppRemoteDataSource remoteDataSource;

  TraineeAppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TraineeAppProfile> getMyProfile() async {
    return await remoteDataSource.getMyProfile();
  }

  @override
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  }) async {
    return await remoteDataSource.updateMyProfile(
      fullName: fullName,
      fitnessGoal: fitnessGoal,
    );
  }

  @override
  Future<CoachProfile> getMyCoach() async {
    return await remoteDataSource.getMyCoach();
  }
}
