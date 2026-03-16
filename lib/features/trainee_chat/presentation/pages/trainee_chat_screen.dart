import 'package:flutter/material.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TraineeChatScreen extends StatelessWidget {
  const TraineeChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coach Mahmoud',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMessage(
                  text:
                      'Hey Coach, I hit a PR on bench press today! 225lbs for 3 reps.',
                  isMe: true,
                  time: '10:45 AM',
                ),
                _buildMessage(
                  text:
                      'That\'s incredible Alex! Great job. We\'ll increase your working weight next week.',
                  isMe: false,
                  time: '10:52 AM',
                ),
                _buildMessage(
                  text:
                      'Also I was wondering about my protein intake, should I increase it on rest days?',
                  isMe: true,
                  time: '11:15 AM',
                ),
                _buildMessage(
                  text:
                      'No, keep it the same to promote recovery. Consistency is key.',
                  isMe: false,
                  time: '11:20 AM',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Type a message...',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required String text,
    required bool isMe,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight:
                    isMe ? const Radius.circular(4) : const Radius.circular(16),
                bottomLeft:
                    !isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
