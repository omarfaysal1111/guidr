import '../../domain/entities/coach_profile.dart';

abstract class CoachRepository {
  Future<CoachProfile> getMyProfile();
  Future<CoachProfile> updateMyProfile({
    String? fullName,
    String? specialisation,
    String? bio,
  });
}
