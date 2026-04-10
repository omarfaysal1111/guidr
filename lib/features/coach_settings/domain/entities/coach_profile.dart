import 'package:equatable/equatable.dart';

class CoachProfile extends Equatable {
  final String id;
  /// Backend user id (Long); used for `coachId` on v1 coach APIs when present.
  final int? userId;
  final String fullName;
  final String email;
  final String? specialisation;
  final int? traineeCount;
  final String? bio;
/*

  "id": 1,
        "userId": 1,
        "fullName": "John Coach",
        "email": "john.coach@fitcoach.com",
        "specialisation": "Strength & Conditioning",
        "bio": "10+ years helping athletes reach peak performance.",
        "traineeCount": 0,
        "createdAt": "2026-03-05T08:56:18.94705"
 */
  const CoachProfile({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    this.specialisation,
    this.traineeCount,
    this.bio,
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    int? toUserId(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return CoachProfile(
      id: json['id']?.toString() ?? '',
      userId: toUserId(json['userId']) ?? toUserId(json['id']),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      specialisation: json['specialisation'],
      bio: json['bio'],
      traineeCount: json['traineeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'fullName': fullName,
      'email': email,
      'specialisation': specialisation,
      'bio': bio,
      'traineeCount': traineeCount,
    };
  }

  @override
  List<Object?> get props => [id, userId, fullName, email, specialisation, bio];
}
