import 'dart:io';
import 'package:guidr/core/network/api_client.dart';
import 'package:guidr/features/trainees/domain/entities/inbody_report.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../../domain/entities/trainee_measurement.dart';
import '../../domain/entities/trainee_progress_picture.dart';

abstract class TraineeProgressRemoteDataSource {
  Future<List<TraineeMeasurement>> getMyMeasurements();
  Future<TraineeMeasurement> addMeasurement(Map<String, dynamic> data);
  Future<List<TraineeProgressPicture>> getMyProgressPictures();
  Future<TraineeProgressPicture> addProgressPicture(Map<String, dynamic> data);
  Future<List<InBodyReport>> getMyInBodyReports();
  Future<TraineeProgressPicture> uploadProgressPhoto({
    String? frontPath,
    String? sidePath,
    String? backPath,
    String? notes,
  });
  Future<InBodyReport> uploadInBodyReport({
    required String filePath,
    String? label,
  });
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

  @override
  Future<List<InBodyReport>> getMyInBodyReports() async {
    final response = await apiClient.get('/trainees/me/inbody-reports');
    final data = response['data'];
    if (data is List) {
      return parseInBodyReportsList(data);
    }
    final nested = data is Map<String, dynamic>
        ? (data['inbodyReports'] ?? data['inbody_reports'])
        : null;
    if (nested is List) {
      return parseInBodyReportsList(nested);
    }
    final top = response['inbodyReports'] ?? response['inbody_reports'];
    if (top is List) {
      return parseInBodyReportsList(top);
    }
    return [];
  }

  @override
  Future<TraineeProgressPicture> uploadProgressPhoto({
    String? frontPath,
    String? sidePath,
    String? backPath,
    String? notes,
  }) async {
    final today = DateTime.now();
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // The backend accepts exactly ONE file per request under the field name
    // 'photo' (also: file / image / picture). Upload each angle separately.
    TraineeProgressPicture? result;

    Future<void> uploadOne(String path, String angle) async {
      final mimeType = lookupMimeType(path) ?? 'image/jpeg';
      final parts = mimeType.split('/');
      final multipartFile = await http.MultipartFile.fromPath(
        'photo',
        path,
        contentType: http.MediaType(parts[0], parts[1]),
      );

      final fields = <String, String>{'date': date, 'angle': angle};
      if (notes != null && notes.isNotEmpty) fields['notes'] = notes;

      final response = await apiClient.postMultipart(
        '/trainees/me/progress-pictures',
        file: multipartFile,
        fields: fields,
      );
      final responseData = response['data'] ?? response;
      result = TraineeProgressPicture.fromJson(responseData);
    }

    if (frontPath != null) await uploadOne(frontPath, 'front');
    if (sidePath != null) await uploadOne(sidePath, 'side');
    if (backPath != null) await uploadOne(backPath, 'back');

    if (result == null) throw Exception('No photos were provided for upload');
    return result!;
  }

  @override
  Future<InBodyReport> uploadInBodyReport({
    required String filePath,
    String? label,
  }) async {
    final file = File(filePath);
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final parts = mimeType.split('/');
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: http.MediaType(parts[0], parts[1]),
    );

    final fields = <String, String>{};
    if (label != null && label.isNotEmpty) fields['label'] = label;

    final response = await apiClient.postMultipart(
      '/trainees/me/inbody-reports',
      file: multipartFile,
      fields: fields,
    );
    final responseData = response['data'] ?? response;
    return InBodyReport.fromJson(responseData);
  }
}
