import 'package:equatable/equatable.dart';

/// Daily water total from `GET/PUT /trainees/me/water-intake` or coach mirror route.
class WaterIntakeDay extends Equatable {
  const WaterIntakeDay({
    required this.liters,
    required this.date,
    this.updatedAt,
  });

  final double liters;
  /// `yyyy-MM-dd` (local calendar day from API).
  final String date;
  final DateTime? updatedAt;

  static String formatDate(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  factory WaterIntakeDay.fromJson(Map<String, dynamic> json) {
    final rawLiters = json['liters'];
    final liters = rawLiters is num
        ? rawLiters.toDouble()
        : double.tryParse(rawLiters?.toString() ?? '') ?? 0;
    final dateStr = json['date']?.toString() ?? '';
    final updatedRaw = json['updatedAt'] ?? json['updated_at'];
    DateTime? updatedAt;
    if (updatedRaw is String) {
      updatedAt = DateTime.tryParse(updatedRaw);
    } else if (updatedRaw is int) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedRaw);
    }
    return WaterIntakeDay(
      liters: liters,
      date: dateStr,
      updatedAt: updatedAt,
    );
  }

  static WaterIntakeDay emptyForDate(DateTime day) {
    return WaterIntakeDay(
      liters: 0,
      date: formatDate(DateTime(day.year, day.month, day.day)),
      updatedAt: null,
    );
  }

  @override
  List<Object?> get props => [liters, date, updatedAt];
}
