import 'package:equatable/equatable.dart';

/// Represents a trainee/client that needs coach attention.
/// Alert types: 'missed', 'nutrition', 'noLogin', 'plateau'
class AttentionItem extends Equatable {
  final String id;
  final String traineeId;
  final String clientName;
  final String message;
  final String alertType;

  const AttentionItem({
    required this.id,
    required this.traineeId,
    required this.clientName,
    required this.message,
    required this.alertType,
  });

  factory AttentionItem.fromJson(Map<String, dynamic> json) {
    return AttentionItem(
      id: json['id']?.toString() ?? '',
      traineeId: json['traineeId']?.toString() ?? '',
      clientName: json['traineeName'] as String? ?? json['clientName'] as String? ?? 'Unknown',
      message: json['message'] as String? ?? '',
      alertType: json['type'] as String? ?? json['alertType'] as String? ?? 'missed',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'traineeId': traineeId,
        'traineeName': clientName,
        'message': message,
        'type': alertType,
      };

  @override
  List<Object?> get props => [id, traineeId, clientName, message, alertType];
}
