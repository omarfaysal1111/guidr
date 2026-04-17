import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/core/widgets/progress_bar.dart';
import 'package:guidr/core/widgets/stat_card.dart';
import 'package:guidr/features/home/domain/entities/coach_home_models.dart';
import 'package:guidr/features/home/domain/usecases/get_coach_home_use_case.dart';
import 'package:guidr/features/home/presentation/bloc/home_bloc.dart';
import 'package:guidr/features/home/presentation/widgets/needs_attention_section.dart';
import 'package:guidr/features/needs_attention/domain/usecases/get_needs_attention_use_case.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';
import 'package:guidr/features/trainees/presentation/bloc/trainees_bloc.dart';
import 'package:guidr/features/trainees/presentation/pages/trainee_profile_screen.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        di.sl<GetCoachHomeUseCase>(),
        di.sl<GetNeedsAttentionUseCase>(),
      )..add(LoadHomeDataEvent()),
      child: const HomeView(),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  /// Returns a time-appropriate greeting.
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Guider',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              int alertCount = 0;
              if (state is HomeLoaded) {
                alertCount = state.coachData.needsAttention +
                    state.pendingInvitations.length;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      if (alertCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$alertCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
          }
          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 52,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<HomeBloc>().add(LoadHomeDataEvent()),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is HomeLoaded) {
            return _buildLoaded(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    final data = state.coachData;
    final todaysSessions = state.todaysSessions;
    final topPerformers = state.topPerformers;
    final pendingInvitations = state.pendingInvitations;

    final sessionsCompleted =
        todaysSessions.where((t) => t.sessionCompletedToday).length;
    final todaySubtitle = todaysSessions.isEmpty
        ? 'None scheduled'
        : sessionsCompleted == todaysSessions.length
            ? 'All ${todaysSessions.length} completed'
            : sessionsCompleted == 0
                ? '${todaysSessions.length} scheduled'
                : '$sessionsCompleted of ${todaysSessions.length} completed';
    final sessionPreview = todaysSessions.take(2).toList();

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<HomeBloc>().add(LoadHomeDataEvent()),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Greeting ───────────────────────────────────────────────────
          Text(
            '${_greeting()}, ${data.name}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: '${data.dateString}  ·  '),
                TextSpan(
                  text: '${data.sessionsToday} sessions today',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (data.needsAttention > 0) ...[
                  const TextSpan(text: '  ·  '),
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

          const SizedBox(height: 20),

          // ── Free Plan Banner ────────────────────────────────────────────
          if (!data.isPremium) ...[
            _FreemiumBanner(
              activeClients: data.activeClients,
              maxClients: data.maxClients,
            ),
            const SizedBox(height: 16),
          ],

          // ── Stats Grid ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: data.activeClients.toString(),
                  label: 'Active',
                  color: AppColors.primary,
                  fontsize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: '${data.avgAdherence}%',
                  label: 'Avg Adherence',
                  color: AppColors.warning,
                  fontsize: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: data.sessionsToday.toString(),
                  label: 'Sessions Today',
                  color: AppColors.textPrimary,
                  fontsize: 8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: data.needsAttention.toString(),
                  label: 'Alerts',
                  color: AppColors.error,
                  fontsize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Needs Attention ─────────────────────────────────────────────
          _SectionCard(
            child: NeedsAttentionSection(
              items: data.needsAttentionItems,
              onViewAll: () {},
              onItemTap: (_) {},
            ),
          ),

          const SizedBox(height: 14),

          // ── Today's Sessions ────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TodaysSessionsSectionHeader(summary: todaySubtitle),
                const SizedBox(height: 12),
                if (todaysSessions.isEmpty)
                  const _EmptyCard(
                    message: 'No sessions scheduled for today.',
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < sessionPreview.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          _TraineeSessionCard(trainee: sessionPreview[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Top Performers ──────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Top Performers',
                  subtitle: 'View all',
                ),
                const SizedBox(height: 12),
                if (topPerformers.isEmpty)
                  const _EmptyCard(
                    message: 'Your most engaged clients will appear here.',
                  )
                else
                  Column(
                    children: topPerformers
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => _TopPerformerRow(
                            index: e.key + 1,
                            trainee: e.value,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Recent Activity ─────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Recent Activity', subtitle: 'All'),
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
                            title: "${t.fullName} completed today's workout",
                            subtitle: 'Updated from weekly adherence data',
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Pending Invitations ─────────────────────────────────────────
          _SectionCard(
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
                        'No pending invites. Invite a trainee to get started.',
                  )
                else
                  Column(
                    children: pendingInvitations
                        .map((inv) => _InvitationCard(invitation: inv))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card Container ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Freemium Banner ──────────────────────────────────────────────────────────

class _FreemiumBanner extends StatelessWidget {
  final int activeClients;
  final int maxClients;

  const _FreemiumBanner({
    required this.activeClients,
    required this.maxClients,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.06),
            blurRadius: 12,
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
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: AppColors.warning,
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
                icon: const Icon(Icons.star_rounded, size: 14),
                label: const Text('Upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
                '$activeClients/$maxClients',
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
            value: activeClients.toDouble(),
            max: maxClients.toDouble(),
            color: AppColors.warning,
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.warning),
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
    );
  }
}

// ─── Today's Sessions Header ──────────────────────────────────────────────────

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
              color: AppColors.primary.withValues(alpha: 0.3),
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

// ─── Section Header ───────────────────────────────────────────────────────────

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
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ─── Empty State Card ─────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
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

// ─── Trainee Session Card ─────────────────────────────────────────────────────

class _TraineeSessionCard extends StatelessWidget {
  static const double _cardWidth = 136;
  static const double _cardHeight = 96;

  final CoachHomeTrainee trainee;

  const _TraineeSessionCard({required this.trainee});

  @override
  Widget build(BuildContext context) {
    final initial =
        trainee.fullName.isNotEmpty ? trainee.fullName[0].toUpperCase() : '?';
    final completed = trainee.sessionCompletedToday;
    final w = trainee.assignedWorkoutName?.trim();
    final g = trainee.fitnessGoal?.trim();
    final workoutTitle =
        (w != null && w.isNotEmpty) ? w : (g != null && g.isNotEmpty) ? g : 'Workout';

    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
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
                    child: _SessionCompletionTag(completed: completed),
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

// ─── Session Completion Tag ───────────────────────────────────────────────────

class _SessionCompletionTag extends StatelessWidget {
  final bool completed;

  const _SessionCompletionTag({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: completed ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            size: 13,
            color: completed ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            completed ? 'Completed' : 'Pending',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: completed ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Performer Row ────────────────────────────────────────────────────────

class _TopPerformerRow extends StatelessWidget {
  final int index;
  final CoachHomeTrainee trainee;

  const _TopPerformerRow({required this.index, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final initial =
        trainee.fullName.isNotEmpty ? trainee.fullName[0].toUpperCase() : '?';
    final adherence = trainee.adherence ?? 0;
    final adherenceColor = adherence >= 80
        ? AppColors.success
        : adherence >= 60
            ? AppColors.warning
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index == 1
                  ? const Color(0xFFFEF9C3)
                  : index == 2
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: index == 1
                    ? const Color(0xFFFDE047)
                    : AppColors.border,
              ),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: index == 1
                    ? const Color(0xFFD97706)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
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
                    color: AppColors.textPrimary,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: adherenceColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent Activity Row ──────────────────────────────────────────────────────

class _RecentActivityRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RecentActivityRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
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
                    color: AppColors.textPrimary,
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

// ─── Invitation Card ──────────────────────────────────────────────────────────

class _InvitationCard extends StatelessWidget {
  final CoachHomeInvitation invitation;

  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
