import 'package:equatable/equatable.dart';

enum ChatSenderRole { coach, trainee }

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final ChatSenderRole senderRole;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderRole,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, text, senderId, senderRole, createdAt];
}
