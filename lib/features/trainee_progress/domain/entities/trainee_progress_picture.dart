import 'package:equatable/equatable.dart';

class TraineeProgressPicture extends Equatable {
  final int id;
  final String date;
  final String? frontPictureUrl;
  final String? sidePictureUrl;
  final String? backPictureUrl;
  final String? notes;
  final String? uploadedAt;

  const TraineeProgressPicture({
    required this.id,
    required this.date,
    this.frontPictureUrl,
    this.sidePictureUrl,
    this.backPictureUrl,
    this.notes,
    this.uploadedAt,
  });

  factory TraineeProgressPicture.fromJson(Map<String, dynamic> json) {
    return TraineeProgressPicture(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      frontPictureUrl: json['frontPictureUrl'] as String?,
      sidePictureUrl: json['sidePictureUrl'] as String?,
      backPictureUrl: json['backPictureUrl'] as String?,
      notes: json['notes'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        frontPictureUrl,
        sidePictureUrl,
        backPictureUrl,
        notes,
        uploadedAt,
      ];
}
