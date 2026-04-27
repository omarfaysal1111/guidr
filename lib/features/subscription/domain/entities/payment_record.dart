class PaymentRecord {
  final int paymentId;
  final String desiredPlan;
  final String paymentMethod;
  final double claimedAmount;
  final double? ocrExtractedAmount;
  final String status;       // PENDING | APPROVED | REJECTED
  final String? reviewNote;
  final DateTime createdAt;

  const PaymentRecord({
    required this.paymentId,
    required this.desiredPlan,
    required this.paymentMethod,
    required this.claimedAmount,
    this.ocrExtractedAmount,
    required this.status,
    this.reviewNote,
    required this.createdAt,
  });

  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      paymentId: json['paymentId'] as int? ?? 0,
      desiredPlan: json['desiredPlan'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      claimedAmount: (json['claimedAmount'] as num?)?.toDouble() ?? 0,
      ocrExtractedAmount: (json['ocrExtractedAmount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      reviewNote: json['reviewNote'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
