import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import 'package:guidr/features/trainee_app/domain/entities/water_intake_day.dart';

abstract class TraineesRepository {
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
  Future<WaterIntakeDay> getTraineeWaterIntake(String traineeId, {DateTime? date});
}
