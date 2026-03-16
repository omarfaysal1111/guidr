import 'package:equatable/equatable.dart';
import 'package:guidr/features/coach_settings/domain/entities/coach_profile.dart';

class CoachHomeResponse extends Equatable {
  final CoachProfile coach;
  final List<CoachHomeTrainee> trainees;
  final List<CoachHomeInvitation> invitations;

  const CoachHomeResponse({
    required this.coach,
    required this.trainees,
    required this.invitations,
  });

  factory CoachHomeResponse.fromJson(Map<String, dynamic> json) {
    return CoachHomeResponse(
      coach: CoachProfile.fromJson(json['coach'] as Map<String, dynamic>),
      trainees: (json['trainees'] as List? ?? [])
          .map((e) => CoachHomeTrainee.fromJson(e as Map<String, dynamic>))
          .toList(),
      invitations: (json['invitations'] as List? ?? [])
          .map((e) => CoachHomeInvitation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [coach, trainees, invitations];
}

class CoachHomeTrainee extends Equatable {
  final int id;
  final int userId;
  final String fullName;
  final String email;
  final String? fitnessGoal;
  final double? adherence;

  const CoachHomeTrainee({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.fitnessGoal,
    this.adherence,
  });

  factory CoachHomeTrainee.fromJson(Map<String, dynamic> json) {
    double? parseAdherence(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return CoachHomeTrainee(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      fitnessGoal: json['fitnessGoal'],
      adherence: (json['adherencePrecent']),
    );
  }

  @override
  List<Object?> get props => [id, userId, fullName, email, fitnessGoal, adherence];
}

class CoachHomeInvitation extends Equatable {
  final String token;
  final String inviteeEmail;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  const CoachHomeInvitation({
    required this.token,
    required this.inviteeEmail,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory CoachHomeInvitation.fromJson(Map<String, dynamic> json) {
    return CoachHomeInvitation(
      token: json['token'] ?? '',
      inviteeEmail: json['inviteeEmail'] ?? '',
      status: json['status'] ?? 'PENDING',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [token, inviteeEmail, status, expiresAt, createdAt];
}

