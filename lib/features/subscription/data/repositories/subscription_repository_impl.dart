import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() =>
      remoteDataSource.getSubscriptionStatus();

  @override
  Future<PaymentRecord> submitPayment({
    required String desiredPlan,
    required String paymentMethod,
    required double transferredAmount,
    required List<int> imageBytes,
    required String fileName,
  }) =>
      remoteDataSource.submitPayment(
        desiredPlan: desiredPlan,
        paymentMethod: paymentMethod,
        transferredAmount: transferredAmount,
        imageBytes: imageBytes,
        fileName: fileName,
      );

  @override
  Future<List<PaymentRecord>> getPaymentHistory() =>
      remoteDataSource.getPaymentHistory();
}
