import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/coach_trainee_detail.dart';

abstract class TraineesRepository {
  Future<List<Trainee>> getMyTrainees();
  Future<List<Invitation>> getMyInvitations();
  Future<Invitation> createInvitation(String email);
  Future<CoachTraineeDetail> getTraineeDetails(String id);
  Future<void> updateTraineeGoalLevel(String id, String goal, String level);
}
