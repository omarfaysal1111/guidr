import 'package:guidr/core/network/api_client.dart';
import 'package:guidr/features/home/domain/entities/coach_home_models.dart';

class HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSource({required this.apiClient});

  Future<CoachHomeResponse> getCoachHome() async {
    final response = await apiClient.get('/coaches/home');
    final data =
        (response['data'] as Map<String, dynamic>?) ?? response;
    return CoachHomeResponse.fromJson(data);
  }
}

