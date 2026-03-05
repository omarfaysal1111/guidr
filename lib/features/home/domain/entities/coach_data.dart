import 'package:equatable/equatable.dart';

class CoachData extends Equatable {
  final String name;
  final String dateString;
  final int sessionsToday;
  final int needsAttention;
  final bool isPremium;
  final int activeClients;
  final int maxClients;
  final int avgAdherence;

  const CoachData({
    required this.name,
    required this.dateString,
    required this.sessionsToday,
    required this.needsAttention,
    required this.isPremium,
    required this.activeClients,
    required this.maxClients,
    required this.avgAdherence,
  });

  @override
  List<Object?> get props => [
        name,
        dateString,
        sessionsToday,
        needsAttention,
        isPremium,
        activeClients,
        maxClients,
        avgAdherence,
      ];
}
