import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/core/widgets/progress_bar.dart';
import 'package:guidr/core/widgets/stat_card.dart';
import 'package:guidr/features/home/presentation/widgets/needs_attention_section.dart';
import 'package:guidr/features/home/presentation/bloc/home_bloc.dart';
import 'package:guidr/features/home/domain/entities/coach_home_models.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';
import 'package:guidr/features/trainees/presentation/bloc/trainees_bloc.dart';
import 'package:guidr/features/trainees/presentation/pages/trainee_profile_screen.dart';
import 'package:guidr/features/needs_attention/domain/usecases/get_needs_attention_use_case.dart';
import 'package:guidr/features/home/domain/usecases/get_coach_home_use_case.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        di.sl<GetCoachHomeUseCase>(),
        di.sl<GetNeedsAttentionUseCase>(),
      )..add(LoadHomeDataEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guider'),
        actions: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              int alertCount = 0;
              if (state is HomeLoaded) {
                alertCount = state.coachData.needsAttention +
                    state.pendingInvitations.length;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  if (alertCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$alertCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is HomeError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else if (state is HomeLoaded) {
            final data = state.coachData;
            final todaysSessions = state.todaysSessions;
            final sessionsCompletedToday = todaysSessions
                .where((t) => t.sessionCompletedToday)
                .length;
            final todaySessionsSubtitle =
                todaysSessions.isEmpty
                    ? 'None scheduled'
                    : sessionsCompletedToday == todaysSessions.length
                    ? 'All ${todaysSessions.length} completed'
                    : sessionsCompletedToday == 0
                    ? '${todaysSessions.length} scheduled'
                    : '$sessionsCompletedToday of ${todaysSessions.length} completed';
            final todaysSessionsPreview = todaysSessions.take(2).toList();
            final topPerformers = state.topPerformers;
            final pendingInvitations = state.pendingInvitations;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // Header: greeting + date + summary
                  Text(
                    'Good evening, ${data.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: '${data.dateString} · '),
                        TextSpan(
                          text: '${data.sessionsToday} sessions today',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (data.needsAttention > 0) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: '${data.needsAttention} need attention',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Free plan + stats card (top)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                 
                  // RichText(
                  //   text: TextSpan(
                  //     style: const TextStyle(
                  //       fontSize: 14,
                  //       color: AppColors.textSecondary,
                  //     ),
                  //     children: [
                  //       TextSpan(text: '${data.dateString} · '),
                  //       TextSpan(
                  //         text: '${data.sessionsToday} sessions today',
                  //         style: const TextStyle(fontWeight: FontWeight.w600),
                  //       ),
                  //       if (data.needsAttention > 0) ...[
                  //         const TextSpan(text: ' · '),
                  //         TextSpan(
                  //           text: '${data.needsAttention} need attention',
                  //           style: const TextStyle(
                  //             color: AppColors.error,
                  //             fontWeight: FontWeight.w700,
                  //           ),
                  //         ),
                  //       ],
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 24),

                  // Freemium Banner (Free Plan)
                  if (!data.isPremium)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.flash_on,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Free Plan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.star, size: 14),
                                label: const Text('Upgrade'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Clients',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${data.activeClients}/${data.maxClients}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomProgressBar(
                            value: data.activeClients.toDouble(),
                            max: data.maxClients.toDouble(),
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Client limit reached — upgrade to add more',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Stats Grid
                  Row(
                    children: [
                      StatCard(
                        value: data.activeClients.toString(),
                        label: 'Active',
                        color: AppColors.primary,
                        fontsize: 11,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: '${data.avgAdherence}%',
                        label: 'Avg Adherence',
                        fontsize: 8,
                         
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: data.sessionsToday.toString(),
                        label: 'Sessions Today',
                        color: AppColors.textPrimary,
                        fontsize: 8,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: data.needsAttention.toString(),
                        label: 'Alerts',
                        color: AppColors.error,
                        fontsize: 11,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Needs Attention card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: NeedsAttentionSection(
                      items: data.needsAttentionItems,
                      onViewAll: () {},
                      onItemTap: (item) {},
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Today's Sessions card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TodaysSessionsSectionHeader(
                          summary: todaySessionsSubtitle,
                        ),
                        const SizedBox(height: 12),
                        if (todaysSessions.isEmpty)
                          const _EmptyCard(
                            message: 'No sessions scheduled for today.',
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < todaysSessionsPreview.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                _TraineeSessionCard(
                                  trainee: todaysSessionsPreview[i],
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Top performers card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: 'Top Performers',
                          subtitle: 'View all',
                        ),
                        const SizedBox(height: 12),
                        if (topPerformers.isEmpty)
                          const _EmptyCard(
                            message: 'You’ll see your most engaged clients here.',
                          )
                        else
                          Column(
                            children: topPerformers
                                .take(3)
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (entry) => _TopPerformerRow(
                                    index: entry.key + 1,
                                    trainee: entry.value,
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recent Activity card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Recent Activity',
                          subtitle: 'All',
                        ),
                        const SizedBox(height: 12),
                        if (topPerformers.isEmpty)
                          const _EmptyCard(
                            message: 'Activity from your clients will appear here.',
                          )
                        else
                          Column(
                            children: topPerformers
                                .take(2)
                                .map(
                                  (t) => _RecentActivityRow(
                                    title:
                                        '${t.fullName} completed today’s workout',
                                    subtitle: 'Auto-generated from adherence',
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pending invitations card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: 'Pending Invitations',
                          subtitle: '${pendingInvitations.length}',
                        ),
                        const SizedBox(height: 12),
                        if (pendingInvitations.isEmpty)
                          const _EmptyCard(
                            message:
                                'No pending invites. Invite a new trainee to start.',
                          )
                        else
                          Column(
                            children: pendingInvitations
                                .map(
                                  (inv) => _InvitationCard(invitation: inv),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ))]),
              
      );}
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TodaysSessionsSectionHeader extends StatelessWidget {
  final String summary;

  const _TodaysSessionsSectionHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Sessions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraineeSessionCard extends StatelessWidget {
  static const double _cardWidth = 132;
  static const double _cardHeight = 92;

  final CoachHomeTrainee trainee;

  const _TraineeSessionCard({required this.trainee});

  @override
  Widget build(BuildContext context) {
    final initial = trainee.fullName.isNotEmpty
        ? trainee.fullName[0].toUpperCase()
        : '?';
    final completed = trainee.sessionCompletedToday;
    final w = trainee.assignedWorkoutName?.trim();
    final g = trainee.fitnessGoal?.trim();
    final workoutTitle =
        (w != null && w.isNotEmpty)
            ? w
            : (g != null && g.isNotEmpty)
            ? g
            : 'Workout';

    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<TraineesBloc>(),
                  child: TraineeProfileScreen(
                    trainee: Trainee(
                      id: trainee.id,
                      name: trainee.fullName,
                      email: trainee.email,
                      missedMealCount: trainee.missedMealCount,
                      missedWorkoutCount: trainee.missedWorkoutCount,
                      avatar: initial,
                      goal: trainee.fitnessGoal ?? 'General Fitness',
                      level: 'Beginner',
                      adherence: (trainee.adherence ?? 0).round(),
                      status: 'active',
                      weight: '—',
                      lastActivity: '—',
                      nextSession: '—',
                      joined: 'Recently',
                      alerts: const [],
                    ),
                    onBackPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trainee.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  height: 1.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                workoutTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: _SessionCompletionTag(
                      completed: completed,
                      compact: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCompletionTag extends StatelessWidget {
  final bool completed;
  final bool compact;

  const _SessionCompletionTag({
    required this.completed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 5.0 : 8.0;
    final vPad = compact ? 2.0 : 4.0;
    final iconSize = compact ? 11.0 : 14.0;
    final fontSize = compact ? 9.0 : 11.0;
    final gap = compact ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: completed ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 10 : 20),
        border: Border.all(
          color:
              completed ? AppColors.success.withValues(alpha: 0.35) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: iconSize,
            color: completed ? AppColors.success : AppColors.textSecondary,
          ),
          SizedBox(width: gap),
          Text(
            completed ? 'Completed' : 'Pending',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: completed ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPerformerRow extends StatelessWidget {
  final int index;
  final CoachHomeTrainee trainee;

  const _TopPerformerRow({
    required this.index,
    required this.trainee,
  });

  @override
  Widget build(BuildContext context) {
    final initial = trainee.fullName.isNotEmpty
        ? trainee.fullName[0].toUpperCase()
        : '?';
    final adherence = trainee.adherence ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainee.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (trainee.fitnessGoal != null &&
                    trainee.fitnessGoal!.isNotEmpty)
                  Text(
                    trainee.fitnessGoal!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${adherence.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RecentActivityRow({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// _StatPill widget was previously used for stats but is no longer referenced.

class _InvitationCard extends StatelessWidget {
  final CoachHomeInvitation invitation;

  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mail_outline,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.inviteeEmail,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Expires ${invitation.expiresAt.toLocal().toString().split(' ').first}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

