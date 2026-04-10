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
  /// Optional coach/internal notes (settings & profile APIs).
  final String? notes;

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
    this.notes,
  });

  @override
  List<Object?> get props => [
        id, name, email, avatar, goal, level, adherence, status, weight,
        lastActivity, nextSession, joined, alerts, notes,
      ];

  static int _parseIntField(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static List<String> _parseAlerts(dynamic raw) {
    if (raw is! List) return const [];
    final out = <String>[];
    for (final e in raw) {
      if (e is String && e.isNotEmpty) {
        out.add(e.toLowerCase().trim());
        continue;
      }
      if (e is Map) {
        final c = e['code']?.toString().toLowerCase().trim();
        if (c != null && c.isNotEmpty) out.add(c);
      }
    }
    return out;
  }

  factory Trainee.fromJson(Map<String, dynamic> json) {
    final notesRaw = json['notes'] ?? json['internalNotes'] ?? json['coachInternalNotes'];
    String? notes;
    if (notesRaw is String && notesRaw.trim().isNotEmpty) {
      notes = notesRaw.trim();
    }

    return Trainee(
      id: _parseIntField(json['id']),
      name: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      avatar: (json['fullName'] as String?)?.isNotEmpty == true
          ? (json['fullName'] as String).substring(0, 1).toUpperCase()
          : '?',
      goal: json['fitnessGoal'] as String? ?? 'General Fitness',
      level: json['traineeLevel']?.toString() ??
          json['level']?.toString() ??
          'Beginner',
      adherence: _parseIntField(json['adherencePercent']),
      status: json['status']?.toString().toLowerCase() ?? 'active',
      weight: '—',
      lastActivity: '—',
      nextSession: '—',
      joined: 'Recently',
      alerts: _parseAlerts(json['alerts'] ?? json['alertCodes'] ?? json['statusAlerts']),
      notes: notes,
    );
  }
}
