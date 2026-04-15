import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidr/features/chat/domain/entities/chat_message_entity.dart';
import 'package:guidr/features/chat/domain/repositories/chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _db;

  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
    return _db.collection('chats').doc(conversationId).collection('messages');
  }

  DocumentReference<Map<String, dynamic>> _chatDoc(String conversationId) {
    return _db.collection('chats').doc(conversationId);
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String conversationId) {
    return _messages(conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
    });
  }

  ChatMessageEntity _fromDoc(String id, Map<String, dynamic> data) {
    final roleStr = data['senderRole'] as String? ?? 'trainee';
    final role = roleStr == 'coach'
        ? ChatSenderRole.coach
        : ChatSenderRole.trainee;
    final ts = data['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else {
      created = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return ChatMessageEntity(
      id: id,
      text: data['text'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderRole: role,
      createdAt: created,
    );
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String coachId,
    required String traineeId,
    required String senderId,
    required ChatSenderRole senderRole,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final batch = _db.batch();
    final chatRef = _chatDoc(conversationId);
    final msgRef = _messages(conversationId).doc();

    batch.set(
      chatRef,
      {
        'coachId': coachId,
        'traineeId': traineeId,
        'lastMessageText': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderRole': senderRole == ChatSenderRole.coach ? 'coach' : 'trainee',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(msgRef, {
      'text': trimmed,
      'senderId': senderId,
      'senderRole': senderRole == ChatSenderRole.coach ? 'coach' : 'trainee',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
