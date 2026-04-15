import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guidr/features/chat/domain/chat_conversation_id.dart';
import 'package:guidr/features/chat/domain/entities/chat_message_entity.dart';
import 'package:guidr/features/chat/presentation/widgets/firebase_chat_thread_view.dart';
import 'package:guidr/features/coach_settings/domain/entities/coach_profile.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';

class TraineeChatScreen extends StatefulWidget {
  const TraineeChatScreen({super.key});

  @override
  State<TraineeChatScreen> createState() => _TraineeChatScreenState();
}

class _TraineeChatScreenState extends State<TraineeChatScreen> {
  late final Future<_TraineeChatBootstrap> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = _load();
  }

  Future<_TraineeChatBootstrap> _load() async {
    final repo = di.sl<TraineeAppRepository>();
    final coach = await repo.getMyCoach();
    final profile = await repo.getMyProfile();
    final conversationId = chatConversationId(
      coachId: coach.id,
      traineeId: profile.id,
    );
    return _TraineeChatBootstrap(
      coach: coach,
      traineeId: profile.id,
      conversationId: conversationId,
    );
  }

  void _showCoachProfile(CoachProfile coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CoachProfileSheet(coach: coach),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TraineeChatBootstrap>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not open chat.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        final coach = data.coach;
        final authId = context.watch<AuthBloc>().state is Authenticated
            ? (context.watch<AuthBloc>().state as Authenticated).user.id
            : data.traineeId;

        final initial = coach.fullName.trim().isNotEmpty
            ? coach.fullName.trim()[0].toUpperCase()
            : '?';

        final appBar = AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.card,
          elevation: 0,
          titleSpacing: 12,
          title: GestureDetector(
            onTap: () => _showCoachProfile(coach),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coach.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '4.9 \u2605',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        coach.specialisation != null &&
                                coach.specialisation!.isNotEmpty
                            ? 'Active now · ${coach.specialisation}'
                            : 'Active now',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        );

        return FirebaseChatThreadView(
          conversationId: data.conversationId,
          coachId: coach.id,
          traineeId: data.traineeId,
          currentUserId: authId,
          myRole: ChatSenderRole.trainee,
          peerTitle: coach.fullName,
          peerSubtitle: coach.specialisation ?? '',
          peerInitial: coach.fullName,
          appBar: appBar,
        );
      },
    );
  }
}

class _TraineeChatBootstrap {
  final CoachProfile coach;
  final String traineeId;
  final String conversationId;

  _TraineeChatBootstrap({
    required this.coach,
    required this.traineeId,
    required this.conversationId,
  });
}

class _CoachProfileSheet extends StatelessWidget {
  final CoachProfile coach;

  const _CoachProfileSheet({required this.coach});

  @override
  Widget build(BuildContext context) {
    final initial = coach.fullName.trim().isNotEmpty
        ? coach.fullName.trim()[0].toUpperCase()
        : '?';
    final bio = (coach.bio != null && coach.bio!.trim().isNotEmpty)
        ? coach.bio!.trim()
        : 'Your coach will add a bio soon.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.specialisation ?? 'Coach',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
