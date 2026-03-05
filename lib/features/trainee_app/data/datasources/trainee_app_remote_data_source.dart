import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/trainee_app_profile.dart';
import '../../../coach_settings/domain/entities/coach_profile.dart';

abstract class TraineeAppRemoteDataSource {
  Future<TraineeAppProfile> getMyProfile();
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  });
  Future<CoachProfile> getMyCoach();
}

class TraineeAppRemoteDataSourceImpl implements TraineeAppRemoteDataSource {
  final ApiClient apiClient;

  TraineeAppRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TraineeAppProfile> getMyProfile() async {
    final response = await apiClient.get('/trainees/me');
    final data = response['data'] ?? response;
    return TraineeAppProfile.fromJson(data);
  }

  @override
  Future<TraineeAppProfile> updateMyProfile({
    String? fullName,
    String? fitnessGoal,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (fitnessGoal != null) body['fitnessGoal'] = fitnessGoal;

    final response = await apiClient.put(
      '/trainees/me',
      body: body,
    );
    final data = response['data'] ?? response;
    return TraineeAppProfile.fromJson(data);
  }

  @override
  Future<CoachProfile> getMyCoach() async {
    final response = await apiClient.get('/trainees/coach');
    final data = response['data'] ?? response;
    return CoachProfile.fromJson(data);
  }
}
