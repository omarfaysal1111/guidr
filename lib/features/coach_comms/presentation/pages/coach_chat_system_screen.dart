import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_comms/presentation/pages/coach_trainee_chat_screen.dart';
import 'package:guidr/features/trainees/presentation/bloc/trainees_bloc.dart';

class CoachChatSystemScreen extends StatelessWidget {
  const CoachChatSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TraineesBloc>()..add(LoadTraineesEvent()),
      child: const _CoachChatSystemView(),
    );
  }
}

class _CoachChatSystemView extends StatelessWidget {
  const _CoachChatSystemView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<TraineesBloc, TraineesState>(
        builder: (context, state) {
          if (state is TraineesLoading || state is TraineesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is! TraineesLoaded) {
            return const Center(child: Text('Something went wrong'));
          }
          final trainees = state.filteredTrainees;
          if (trainees.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No trainees yet.\nInvite someone to start messaging.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: trainees.length,
            itemBuilder: (context, index) {
              final t = trainees[index];
              final initial = t.name.trim().isNotEmpty
                  ? t.name.trim()[0].toUpperCase()
                  : '?';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  t.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  t.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CoachTraineeChatScreen(trainee: t),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
