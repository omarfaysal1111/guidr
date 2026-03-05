import 'package:equatable/equatable.dart';

class Trainee extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final String goal;
  final String level;
  final int adherence;
  final String status; // 'active', 'pending', 'inactive'
  final String weight;
  final String lastActivity;
  final String nextSession;
  final String joined;
  final List<String> alerts; // 'missed', 'nutrition', 'noLogin', 'plateau'

  const Trainee({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.goal,
    required this.level,
    required this.adherence,
    required this.status,
    required this.weight,
    required this.lastActivity,
    required this.nextSession,
    required this.joined,
    required this.alerts,
  });

  @override
  List<Object?> get props => [
        id, name, email, avatar, goal, level, adherence, status, weight,
        lastActivity, nextSession, joined, alerts,
      ];

  factory Trainee.fromJson(Map<String, dynamic> json) {
    return Trainee(
      id: json['id'] as int? ?? 0,
      name: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      avatar: (json['fullName'] as String?)?.isNotEmpty == true
          ? (json['fullName'] as String).substring(0, 1).toUpperCase()
          : '?',
      goal: json['fitnessGoal'] as String? ?? 'General Fitness',
      level: 'Beginner', // Default for now
      adherence: 0,
      status: 'active',
      weight: '—',
      lastActivity: '—',
      nextSession: '—',
      joined: 'Recently',
      alerts: const [],
    );
  }
}
