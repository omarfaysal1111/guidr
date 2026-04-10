import 'package:equatable/equatable.dart';

class TraineeMeasurement extends Equatable {
  final int id;
  final String date;
  final double? weight;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? waterPercentage;
  final double? chest;
  final double? waist;
  final double? arms;
  final double? hips;
  final double? thighs;
  final String? recordedAt;

  const TraineeMeasurement({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.waterPercentage,
    this.chest,
    this.waist,
    this.arms,
    this.hips,
    this.thighs,
    this.recordedAt,
  });

  factory TraineeMeasurement.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return TraineeMeasurement(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      weight: parseDouble(json['weight']),
      bodyFatPercentage: parseDouble(json['bodyFatPercentage']),
      muscleMass: parseDouble(json['muscleMass']),
      waterPercentage: parseDouble(json['waterPercentage']),
      chest: parseDouble(json['chest']),
      waist: parseDouble(json['waist']),
      arms: parseDouble(json['arms']),
      hips: parseDouble(json['hips']),
      thighs: parseDouble(json['thighs']),
      recordedAt: json['recordedAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        weight,
        bodyFatPercentage,
        muscleMass,
        waterPercentage,
        chest,
        waist,
        arms,
        hips,
        thighs,
        recordedAt,
      ];
}
