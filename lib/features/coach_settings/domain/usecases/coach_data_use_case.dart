import 'package:guidr/features/coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/coach_settings/domain/repositories/coach_repository.dart';


class GetCoachDataUseCase {
  final CoachRepository repository;

  GetCoachDataUseCase(this.repository);

  Future<CoachProfile> call() async {
    return await repository.getMyProfile();
  }
}