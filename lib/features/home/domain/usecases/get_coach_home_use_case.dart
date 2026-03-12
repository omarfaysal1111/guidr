import 'package:guidr/features/home/data/datasources/home_remote_data_source.dart';
import 'package:guidr/features/home/domain/entities/coach_home_models.dart';

class GetCoachHomeUseCase {
  final HomeRemoteDataSource remoteDataSource;

  GetCoachHomeUseCase(this.remoteDataSource);

  Future<CoachHomeResponse> call() {
    return remoteDataSource.getCoachHome();
  }
}

