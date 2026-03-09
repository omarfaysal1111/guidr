import 'package:equatable/equatable.dart';

class CoachProfile extends Equatable {
  final String id;
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
    required this.fullName,
    required this.email,
    this.specialisation,
    this.traineeCount,
    this.bio,
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      id: json['id']?.toString() ?? '',
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
      'fullName': fullName,
      'email': email,
      'specialisation': specialisation,
      'bio': bio,
      'traineeCount': traineeCount,
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, specialisation, bio];
}
