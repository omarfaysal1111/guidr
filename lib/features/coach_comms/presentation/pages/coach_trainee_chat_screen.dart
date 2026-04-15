import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guidr/features/chat/domain/chat_conversation_id.dart';
import 'package:guidr/features/chat/domain/entities/chat_message_entity.dart';
import 'package:guidr/features/chat/presentation/widgets/firebase_chat_thread_view.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';

/// 1:1 thread between the signed-in coach and one trainee (Firestore + FCM token sync elsewhere).
class CoachTraineeChatScreen extends StatelessWidget {
  final Trainee trainee;

  const CoachTraineeChatScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in required')),
      );
    }
    final coachId = authState.user.id;
    final traineeId = trainee.id.toString();
    final conversationId = chatConversationId(
      coachId: coachId,
      traineeId: traineeId,
    );

    final initial = trainee.name.trim().isNotEmpty
        ? trainee.name.trim()[0].toUpperCase()
        : '?';

    final appBar = AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trainee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  trainee.goal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );

    return FirebaseChatThreadView(
      conversationId: conversationId,
      coachId: coachId,
      traineeId: traineeId,
      currentUserId: coachId,
      myRole: ChatSenderRole.coach,
      peerTitle: trainee.name,
      peerSubtitle: trainee.goal,
      peerInitial: trainee.name,
      appBar: appBar,
    );
  }
}
