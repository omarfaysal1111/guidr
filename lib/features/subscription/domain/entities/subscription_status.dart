class SubscriptionStatus {
  final String plan;           // TRIAL | BASIC | PREMIUM | ELITE
  final String status;         // ACTIVE | EXPIRED
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int maxClients;        // -1 = unlimited
  final int currentClientCount;
  final int remainingSlots;    // -1 = unlimited
  final bool unlimited;

  const SubscriptionStatus({
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.maxClients,
    required this.currentClientCount,
    required this.remainingSlots,
    required this.unlimited,
  });

  bool get isExpired => !active;
  bool get isTrial => plan == 'TRIAL';

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      plan: json['plan'] as String? ?? 'TRIAL',
      status: json['status'] as String? ?? 'ACTIVE',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      active: json['active'] as bool? ?? false,
      maxClients: json['maxClients'] as int? ?? 0,
      currentClientCount: json['currentClientCount'] as int? ?? 0,
      remainingSlots: json['remainingSlots'] as int? ?? 0,
      unlimited: json['unlimited'] as bool? ?? false,
    );
  }
}
