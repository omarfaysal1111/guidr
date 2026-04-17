import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import '../../domain/repositories/trainees_repository.dart';
import '../datasources/trainees_remote_data_source.dart';

class TraineesRepositoryImpl implements TraineesRepository {
  final TraineesRemoteDataSource remoteDataSource;

  TraineesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Trainee>> getMyTrainees() async {
    return await remoteDataSource.getMyTrainees();
  }

  @override
  Future<List<Invitation>> getMyInvitations() async {
    return await remoteDataSource.getMyInvitations();
  }

  @override
  Future<Invitation> createInvitation(String email) async {
    return await remoteDataSource.createInvitation(email);
  }

  @override
  Future<CoachTraineeDetail> getTraineeDetails(String id) async {
    return await remoteDataSource.getTraineeDetails(id);
  }

  @override
  Future<void> updateTraineeGoalLevel(String id, String goal, String level) async {
    return await remoteDataSource.updateTraineeGoalLevel(id, goal, level);
  }
}
