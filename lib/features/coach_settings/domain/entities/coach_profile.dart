import 'package:equatable/equatable.dart';

class CoachProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? specialisation;
  final String? bio;

  const CoachProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.specialisation,
    this.bio,
  });

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    return CoachProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      specialisation: json['specialisation'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'specialisation': specialisation,
      'bio': bio,
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, specialisation, bio];
}
