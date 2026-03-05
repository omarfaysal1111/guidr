import '../../domain/entities/coach_profile.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_data_source.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachRemoteDataSource remoteDataSource;

  CoachRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CoachProfile> getMyProfile() async {
    return await remoteDataSource.getMyProfile();
  }

  @override
  Future<CoachProfile> updateMyProfile({
    String? fullName,
    String? specialisation,
    String? bio,
  }) async {
    return await remoteDataSource.updateMyProfile(
      fullName: fullName,
      specialisation: specialisation,
      bio: bio,
    );
  }
}
