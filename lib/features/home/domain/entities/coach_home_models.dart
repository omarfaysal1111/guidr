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
  /// Workout / plan title scheduled for today (coach home API).
  final String? assignedWorkoutName;
  final int missedWorkoutCount; // New field for missed workouts
  final int missedMealCount;    // New field for missed meals
  /// Whether the trainee has completed their scheduled session for today (coach home API).
  final bool sessionCompletedToday;

  const CoachHomeTrainee({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.fitnessGoal,
    this.adherence,
    this.assignedWorkoutName,
    this.missedWorkoutCount = 0,
    this.missedMealCount = 0,
    this.sessionCompletedToday = false,
  });

  static bool _parseSessionCompletedToday(Map<String, dynamic> json) {
    const keys = [
      'todaySessionCompleted',
      'sessionCompletedToday',
      'sessionCompleted',
      'todaySessionDone',
      'completedToday',
      'hasCompletedTodaySession',
    ];
    for (final key in keys) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        if (s == 'true' || s == 'completed' || s == 'done') return true;
        if (s == 'false' || s == 'pending') return false;
      }
      if (v is num) return v != 0;
    }
    return false;
  }

  static String? _parseAssignedWorkoutName(Map<String, dynamic> json) {
    const topLevelKeys = [
      'assignedWorkoutName',
      'workoutName',
      'todayWorkoutName',
      'todayPlanName',
      'exercisePlanName',
      'workoutPlanName',
      'planName',
      'sessionWorkoutName',
    ];
    for (final key in topLevelKeys) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    const nestedKeys = [
      'todayWorkout',
      'assignedWorkout',
      'workoutPlan',
      'todaysWorkout',
      'todaySession',
    ];
    for (final nk in nestedKeys) {
      final n = json[nk];
      if (n is Map<String, dynamic>) {
        final name = n['name'] ?? n['title'] ?? n['planName'] ?? n['workoutName'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
    }
    return null;
  }

  factory CoachHomeTrainee.fromJson(Map<String, dynamic> json) {
    return CoachHomeTrainee(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      fitnessGoal: json['fitnessGoal'],
      adherence: double.parse(json['adherencePercent'].toString()),
      assignedWorkoutName: _parseAssignedWorkoutName(json),
      sessionCompletedToday: _parseSessionCompletedToday(json),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    email,
    fitnessGoal,
    adherence,
    assignedWorkoutName,
    sessionCompletedToday,
  ];
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

