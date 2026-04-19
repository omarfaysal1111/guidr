import 'package:http/http.dart' as http;
import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/coach_trainee_detail.dart';

abstract class TraineesRemoteDataSource {
  Future<List<Trainee>> getMyTrainees();
  Future<List<Invitation>> getMyInvitations();
  Future<Invitation> createInvitation(String email);
  Future<CoachTraineeDetail> getTraineeDetails(String id);
  Future<void> updateTraineeGoalLevel(String id, String goal, String level);
  Future<void> saveCoachNotes(String id, String feedback, String caution);
  Future<void> addGoal(String traineeId, String title);
  Future<void> editGoal(String goalId, String newTitle);
  Future<void> toggleGoal(String traineeId, String goalId, bool completed);
  Future<void> deleteGoal(String traineeId, String goalId);
  Future<void> uploadInBodyReport(String traineeId, List<int> fileBytes, String fileName);
  Future<void> uploadProgressPhoto(String traineeId, List<int> fileBytes, String fileName);
  Future<void> archiveTrainee(String id);
  Future<void> deleteTrainee(String id);
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

  @override
  Future<CoachTraineeDetail> getTraineeDetails(String id) async {
    final response = await apiClient.get('/coaches/trainees/$id');
    final data = response['data'] ?? response;
    return CoachTraineeDetail.fromJson(data);
  }

  @override
  Future<void> updateTraineeGoalLevel(String id, String goal, String level) async {
    await apiClient.patch(
      '/coaches/trainees/$id',
      body: {'fitnessGoal': goal, 'traineeLevel': level},
    );
  }

  @override
  Future<void> saveCoachNotes(String id, String feedback, String caution) async {
    await apiClient.put(
      '/coaches/trainees/$id/notes',
      body: {
        'coachFeedback': feedback,
        'cautionNotes': caution,
      },
    );
  }

  @override
  Future<void> addGoal(String traineeId, String title) async {
    await apiClient.post(
      '/coaches/trainees/$traineeId/goals',
      body: {'title': title},
    );
  }

  @override
  Future<void> editGoal(String goalId, String newTitle) async {
    await apiClient.patch(
      '/coaches/goals/$goalId',
      body: {'title': newTitle},
    );
  }

  @override
  Future<void> toggleGoal(String traineeId, String goalId, bool completed) async {
    await apiClient.patch(
      '/coaches/goals/$goalId',
      body: {'status': completed ? 'COMPLETED' : 'IN_PROGRESS'},
    );
  }

  @override
  Future<void> deleteGoal(String traineeId, String goalId) async {
    await apiClient.delete('/coaches/goals/$goalId');
  }

  @override
  Future<void> uploadInBodyReport(String traineeId, List<int> fileBytes, String fileName) async {
    await apiClient.postMultipart(
      '/coaches/trainees/$traineeId/inbody-reports',
      file: http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );
  }

  @override
  Future<void> uploadProgressPhoto(String traineeId, List<int> fileBytes, String fileName) async {
    await apiClient.postMultipart(
      '/coaches/trainees/$traineeId/progress-photos',
      file: http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );
  }

  @override
  Future<void> archiveTrainee(String id) async {
    await apiClient.patch(
      '/coaches/trainees/$id/status',
      body: {'status': 'ARCHIVED'},
    );
  }

  @override
  Future<void> deleteTrainee(String id) async {
    await apiClient.delete('/coaches/trainees/$id');
  }
}
