import '../../domain/entities/trainee_app_profile.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';

abstract class TraineeAppRepository {
  Future<TraineeAppProfile> getMyProfile();
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  });
  Future<CoachProfile> getMyCoach();
}
