import '../entities/subscription_status.dart';
import '../entities/payment_record.dart';

abstract class SubscriptionRepository {
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
