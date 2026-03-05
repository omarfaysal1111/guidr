import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';

abstract class TraineesRepository {
  Future<List<Trainee>> getMyTrainees();
  Future<List<Invitation>> getMyInvitations();
  Future<Invitation> createInvitation(String email);
}
