import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String coachId,
    required String traineeId,
    required String senderId,
    required ChatSenderRole senderRole,
    required String text,
  });
}
