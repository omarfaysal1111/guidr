import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';

abstract class TraineesRemoteDataSource {
  Future<List<Trainee>> getMyTrainees();
  Future<List<Invitation>> getMyInvitations();
  Future<Invitation> createInvitation(String email);
}

class TraineesRemoteDataSourceImpl implements TraineesRemoteDataSource {
  final ApiClient apiClient;

  TraineesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Trainee>> getMyTrainees() async {
    final response = await apiClient.get('/coaches/trainees');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => Trainee.fromJson(e)).toList();
  }

  @override
  Future<List<Invitation>> getMyInvitations() async {
    final response = await apiClient.get('/coaches/invitations');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => Invitation.fromJson(e)).toList();
  }

  @override
  Future<Invitation> createInvitation(String email) async {
    final response = await apiClient.post(
      '/coaches/invitations',
      body: {'email': email},
    );
    final data = response['data'] ?? response;
    return Invitation.fromJson(data);
  }
}
