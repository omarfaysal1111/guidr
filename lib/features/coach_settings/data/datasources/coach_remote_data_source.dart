import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/coach_profile.dart';

abstract class CoachRemoteDataSource {
  Future<CoachProfile> getMyProfile();
  Future<CoachProfile> updateMyProfile({
    String? fullName,
    String? specialisation,
    String? bio,
  });
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  final ApiClient apiClient;

  CoachRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CoachProfile> getMyProfile() async {
    final response = await apiClient.get('/coaches/me');
    final data = response['data'] ?? response;
    return CoachProfile.fromJson(data);
  }

  @override
  Future<CoachProfile> updateMyProfile({
    String? fullName,
    String? specialisation,
    String? bio,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (specialisation != null) body['specialisation'] = specialisation;
    if (bio != null) body['bio'] = bio;

    final response = await apiClient.put(
      '/coaches/me',
      body: body,
    );
    final data = response['data'] ?? response;
    return CoachProfile.fromJson(data);
  }
}
