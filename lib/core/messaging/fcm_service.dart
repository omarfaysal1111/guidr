import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Registers the device for FCM and stores the token in Firestore under
/// `user_fcm_tokens/{userId}` for server-side pushes (e.g. Cloud Functions).
class FcmService {
  FcmService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> syncTokenForUser(String userId) async {
    if (userId.isEmpty) return;
    final messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e, st) {
      debugPrint('FCM permission: $e\n$st');
    }

    try {
      final token = await messaging.getToken();
      if (token != null) {
        await _persistToken(userId, token);
      }
    } catch (e, st) {
      debugPrint('FCM getToken: $e\n$st');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _persistToken(userId, token);
    });
  }

  Future<void> _persistToken(String userId, String token) {
    return _db.collection('user_fcm_tokens').doc(userId).set(
      {
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void listenForegroundMessages(void Function(RemoteMessage) onData) {
    FirebaseMessaging.onMessage.listen(onData);
  }
}
