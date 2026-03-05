import '../../domain/entities/trainee.dart';
import '../../domain/entities/invitation.dart';
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
}
