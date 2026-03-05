import 'package:guidr/core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<String> registerCoach({
    required String fullName,
    required String email,
    required String password,
    String? specialisation,
    String? bio,
  });
  Future<String> registerTrainee({
    required String fullName,
    required String email,
    required String password,
    required String invitationToken,
    String? fitnessGoal,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> login(String email, String password) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );
    return response['data']['token'] as String;
  }

  @override
  Future<String> registerCoach({
    required String fullName,
    required String email,
    required String password,
    String? specialisation,
    String? bio,
  }) async {
    final response = await apiClient.post(
      '/auth/coaches/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (specialisation != null) 'specialisation': specialisation,
        if (bio != null) 'bio': bio,
      },
      requireAuth: false,
    );
    return response['data']['token'] as String;
  }

  @override
  Future<String> registerTrainee({
    required String fullName,
    required String email,
    required String password,
    required String invitationToken,
    String? fitnessGoal,
  }) async {
    final response = await apiClient.post(
      '/auth/trainees/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'invitationToken': invitationToken,
        if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      },
      requireAuth: false,
    );
    return response['data']['token'] as String;
  }
}
