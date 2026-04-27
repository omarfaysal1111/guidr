import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import 'package:guidr/features/trainee_app/domain/entities/water_intake_day.dart';
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

  @override
  Future<void> saveCoachNotes(String id, String feedback, String caution) async {
    return await remoteDataSource.saveCoachNotes(id, feedback, caution);
  }

  @override
  Future<void> addGoal(String traineeId, String title) async {
    return await remoteDataSource.addGoal(traineeId, title);
  }

  @override
  Future<void> editGoal(String goalId, String newTitle) async {
    return await remoteDataSource.editGoal(goalId, newTitle);
  }

  @override
  Future<void> toggleGoal(String traineeId, String goalId, bool completed) async {
    return await remoteDataSource.toggleGoal(traineeId, goalId, completed);
  }

  @override
  Future<void> deleteGoal(String traineeId, String goalId) async {
    return await remoteDataSource.deleteGoal(traineeId, goalId);
  }

  @override
  Future<void> uploadInBodyReport(String traineeId, List<int> fileBytes, String fileName) async {
    return await remoteDataSource.uploadInBodyReport(traineeId, fileBytes, fileName);
  }

  @override
  Future<void> uploadProgressPhoto(String traineeId, List<int> fileBytes, String fileName) async {
    return await remoteDataSource.uploadProgressPhoto(traineeId, fileBytes, fileName);
  }

  @override
  Future<void> archiveTrainee(String id) async {
    return await remoteDataSource.archiveTrainee(id);
  }

  @override
  Future<void> deleteTrainee(String id) async {
    return await remoteDataSource.deleteTrainee(id);
  }

  @override
  Future<WaterIntakeDay> getTraineeWaterIntake(String traineeId, {DateTime? date}) {
    return remoteDataSource.getTraineeWaterIntake(traineeId, date: date);
  }
}
