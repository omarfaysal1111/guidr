import 'package:guidr/core/network/api_client.dart';
import 'package:guidr/core/storage/local_storage.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
    required this.apiClient,
  });

  @override
  Future<User> login(String email, String password) async {
    final token = await remoteDataSource.login(email, password);
    await localStorage.saveToken(token);
    return await _fetchUserProfileAndDetermineRole(email);
  }

  @override
  Future<User> registerCoach({
    required String fullName,
    required String email,
    required String password,
    String? specialisation,
    String? bio,
  }) async {
    final token = await remoteDataSource.registerCoach(
      fullName: fullName,
      email: email,
      password: password,
      specialisation: specialisation,
      bio: bio,
    );
    await localStorage.saveToken(token);
    return await _fetchUserProfileAndDetermineRole(email);
  }

  @override
  Future<User> registerTrainee({
    required String fullName,
    required String email,
    required String password,
    required String invitationToken,
    String? fitnessGoal,
  }) async {
    final token = await remoteDataSource.registerTrainee(
      fullName: fullName,
      email: email,
      password: password,
      invitationToken: invitationToken,
      fitnessGoal: fitnessGoal,
    );
    await localStorage.saveToken(token);
    return await _fetchUserProfileAndDetermineRole(email);
  }

  @override
  Future<void> logout() async {
    await localStorage.deleteToken();
  }

  @override
  Future<User?> getSignedInUser() async {
    final token = localStorage.getToken();
    if (token == null) return null;
    try {
      return await _fetchUserProfileAndDetermineRole('');
    } catch (_) {
      return null;
    }
  }

  Future<User> _fetchUserProfileAndDetermineRole(String fallbackEmail) async {
    try {
      // Try to fetch coach profile
      final response = await apiClient.get('/coaches/me', requireAuth: true);
      final data = response['data'] ?? response;
      return User(
        id: data['id']?.toString() ?? 'unknown',
        email: data['email']?.toString() ?? fallbackEmail,
        role: UserRole.coach,
      );
    } catch (e) {
      // If unauthorized/forbidden or not found, try trainee profile
      try {
        final response = await apiClient.get('/trainees/me', requireAuth: true);
        final data = response['data'] ?? response;
        return User(
          id: data['id']?.toString() ?? 'unknown',
          email: data['email']?.toString() ?? fallbackEmail,
          role: UserRole.trainee,
        );
      } catch (e2) {
        throw Exception('Failed to fetch user profile for role determination.');
      }
    }
  }
}
