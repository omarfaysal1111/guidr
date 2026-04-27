import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_status.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionStatus> getSubscriptionStatus();
  Future<PaymentRecord> submitPayment({
    required String desiredPlan,
    required String paymentMethod,
    required double transferredAmount,
    required List<int> imageBytes,
    required String fileName,
  });
  Future<List<PaymentRecord>> getPaymentHistory();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final response = await apiClient.get('/coaches/payment/subscription');
    final data = response['data'] ?? response;
    return SubscriptionStatus.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PaymentRecord> submitPayment({
    required String desiredPlan,
    required String paymentMethod,
    required double transferredAmount,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final imageSubtype = ext == 'png' ? 'png' : 'jpeg';

    final screenshotFile = http.MultipartFile.fromBytes(
      'screenshot',
      imageBytes,
      filename: fileName,
      contentType: MediaType('image', imageSubtype),
    );

    final dataJson = jsonEncode({
      'desiredPlan': desiredPlan,
      'paymentMethod': paymentMethod,
      'transferredAmount': transferredAmount,
    });
    final dataFile = http.MultipartFile.fromString(
      'data',
      dataJson,
      contentType: MediaType('application', 'json'),
    );

    final response = await apiClient.postMultipartFiles(
      '/coaches/payment/submit',
      files: [screenshotFile, dataFile],
    );
    final data = response['data'] ?? response;
    return PaymentRecord.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<PaymentRecord>> getPaymentHistory() async {
    final response = await apiClient.get('/coaches/payment/history');
    final data = response['data'] as List? ?? [];
    return data.map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>)).toList();
  }
}
