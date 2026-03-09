import 'package:equatable/equatable.dart';
import 'package:guidr/features/needs_attention/domain/entities/attention_item.dart';

class CoachData extends Equatable {
  final String name;
  final String dateString;
  final int sessionsToday;
  final int needsAttention;
  final bool isPremium;
  final int activeClients;
  final int maxClients;
  final int avgAdherence;
  final List<AttentionItem> needsAttentionItems;

  const CoachData({
    required this.name,
    required this.dateString,
    required this.sessionsToday,
    required this.needsAttention,
    required this.isPremium,
    required this.activeClients,
    required this.maxClients,
    required this.avgAdherence,
    this.needsAttentionItems = const [],
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
        needsAttentionItems,
      ];
}
