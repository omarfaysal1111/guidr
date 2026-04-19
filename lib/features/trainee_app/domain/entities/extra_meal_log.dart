import 'package:equatable/equatable.dart';

/// Logged ad-hoc meal from `POST /trainees/me/extra-meals`.
class ExtraMealLog extends Equatable {
  final int? id;
  final int? traineeId;
  final String name;
  final double calories;
  final DateTime date;
  final int? ingredientId;

  const ExtraMealLog({
    this.id,
    this.traineeId,
    required this.name,
    required this.calories,
    required this.date,
    this.ingredientId,
  });

  factory ExtraMealLog.fromJson(Map<String, dynamic> json) {
    DateTime? d;
    final rawDate = json['date'] ?? json['loggedDate'] ?? json['loggedAt'];
    if (rawDate is String && rawDate.isNotEmpty) {
      d = DateTime.tryParse(rawDate);
    }
    return ExtraMealLog(
      id: _readInt(json['id']),
      traineeId: _readInt(json['traineeId'] ?? json['trainee_id']),
      name: json['name']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      date: d ?? DateTime.now(),
      ingredientId: _readInt(json['ingredientId'] ?? json['ingredient_id']),
    );
  }

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  List<Object?> get props => [id, traineeId, name, calories, date, ingredientId];
}
