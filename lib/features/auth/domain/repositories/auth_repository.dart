import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> registerCoach({
    required String fullName,
    required String email,
    required String password,
    String? specialisation,
    String? bio,
  });
  Future<User> registerTrainee({
    required String fullName,
    required String email,
    required String password,
    required String invitationToken,
    String? fitnessGoal,
  });
  Future<void> logout();
  Future<User?> getSignedInUser();
}
