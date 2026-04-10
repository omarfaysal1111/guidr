import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';

abstract class TraineeProgressRemoteDataSource {
  Future<List<TraineeMeasurement>> getMyMeasurements();
  Future<TraineeMeasurement> addMeasurement(Map<String, dynamic> data);
  Future<List<TraineeProgressPicture>> getMyProgressPictures();
  Future<TraineeProgressPicture> addProgressPicture(Map<String, dynamic> data);
}

class TraineeProgressRemoteDataSourceImpl implements TraineeProgressRemoteDataSource {
  final ApiClient apiClient;

  TraineeProgressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TraineeMeasurement>> getMyMeasurements() async {
    final response = await apiClient.get('/trainees/me/measurements');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => TraineeMeasurement.fromJson(e)).toList();
  }

  @override
  Future<TraineeMeasurement> addMeasurement(Map<String, dynamic> data) async {
    final response = await apiClient.post('/trainees/me/measurements', body: data);
    final responseData = response['data'] ?? response;
    return TraineeMeasurement.fromJson(responseData);
  }

  @override
  Future<List<TraineeProgressPicture>> getMyProgressPictures() async {
    final response = await apiClient.get('/trainees/me/progress-pictures');
    final data = response['data'] as List? ?? response as List;
    return data.map((e) => TraineeProgressPicture.fromJson(e)).toList();
  }

  @override
  Future<TraineeProgressPicture> addProgressPicture(Map<String, dynamic> data) async {
    final response = await apiClient.post('/trainees/me/progress-pictures', body: data);
    final responseData = response['data'] ?? response;
    return TraineeProgressPicture.fromJson(responseData);
  }
}
