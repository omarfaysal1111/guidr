import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/trainees_bloc.dart';
import '../widgets/trainee_profile_plans_tab.dart';
import '../widgets/trainee_profile_progress_tab.dart';
import '../widgets/trainee_profile_settings_tab.dart';
import '../widgets/health_training_history_sheet.dart';
import '../../domain/entities/trainee.dart';
import '../../domain/entities/trainee_health_history.dart';

class TraineeProfileScreen extends StatefulWidget {
  final Trainee trainee;
  final VoidCallback onBackPressed;

  const TraineeProfileScreen({
    super.key,
    required this.trainee,
    required this.onBackPressed,
  });

  @override
  State<TraineeProfileScreen> createState() => _TraineeProfileScreenState();
}

class _TraineeProfileScreenState extends State<TraineeProfileScreen> {
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TraineesBloc>().add(LoadTraineeDetailEvent(widget.trainee.id.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trainee;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.card,
              shape: const CircleBorder(),
              side: const BorderSide(color: AppColors.border),
            ),
            icon: const Icon(Icons.chevron_left, size: 22),
            onPressed: widget.onBackPressed,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${t.goal} • ${t.level}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.card,
                shape: const CircleBorder(),
                side: const BorderSide(color: AppColors.border),
              ),
              icon: const Icon(Icons.more_vert, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SegmentedTabs(
              activeIndex: _activeTabIndex,
              onChanged: (i) => setState(() => _activeTabIndex = i),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<TraineesBloc, TraineesState>(
              builder: (context, state) {
                if (state is TraineesLoaded) {
                  return _buildContent(t, state);
                }
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Trainee t, TraineesLoaded state) {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverview(t, state);
      case 1:
        return TraineeProfilePlansTab(
          detail: state.traineeDetail,
          loading: state.traineeDetailLoading,
        );
      case 2:
        return TraineeProfileProgressTab(
          detail: state.traineeDetail,
          loading: state.traineeDetailLoading,
        );
      case 3:
        return TraineeProfileSettingsTab(
          trainee: t,
          profileFromDetail: state.traineeDetail?.profile,
          detailLoading: state.traineeDetailLoading,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Trainee _resolvedProfile(Trainee t, TraineesLoaded state) {
    return state.traineeDetail?.profile ?? t;
  }

  String _resolvedWeight(Trainee t, TraineesLoaded state) {
    final m = state.traineeDetail?.recentMeasurements;
    if (m != null && m.isNotEmpty && m.first.weight != null) {
      return '${m.first.weight!.toStringAsFixed(0)} kg';
    }
    if (t.weight != '—' && t.weight.isNotEmpty) return t.weight;
    return '—';
  }

  Widget _buildOverview(Trainee t, TraineesLoaded state) {
    final p = _resolvedProfile(t, state);
    final weightDisplay = _resolvedWeight(t, state);
    final adherence = p.adherence.clamp(0, 100);
    final adherenceColor =
        adherence >= 70 ? AppColors.success : adherence >= 50 ? AppColors.warning : AppColors.error;

    const weekTotal = 5;
    final workoutDone = (adherence * weekTotal / 100).round().clamp(0, weekTotal);
    final workoutPct = weekTotal == 0 ? 0 : ((100 * workoutDone / weekTotal).round());
    final nutritionDone =
        (adherence * weekTotal / 100 * 0.55).round().clamp(0, weekTotal);
    final nutritionPct = weekTotal == 0 ? 0 : ((100 * nutritionDone / weekTotal).round());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      p.avatar,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.goal} • ${p.level}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  final history = state.traineeDetail?.healthHistory ??
                      TraineeHealthHistory.fallback(p);
                  showHealthTrainingHistorySheet(context, history);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.post_add_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Health & Training History',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _OverviewMetricTile(
                      value: '$adherence%',
                      valueColor: adherenceColor,
                      label: 'ADHERENCE',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: _OverviewMetricTile(
                      value: '—',
                      valueColor: AppColors.textPrimary,
                      label: 'DAY STREAK',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OverviewMetricTile(
                      value: weightDisplay,
                      valueColor: AppColors.textPrimary,
                      label: 'WEIGHT',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'DIRECTION / GOAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.track_changes, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.goal,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Trainee Level',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          p.level,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ..._buildOverviewAlerts(p),
        const SizedBox(height: 16),
        _WeeklySummaryCard(
          workoutDone: workoutDone,
          workoutTotal: weekTotal,
          workoutPct: workoutPct,
          nutritionDone: nutritionDone,
          nutritionTotal: weekTotal,
          nutritionPct: nutritionPct,
        ),
        const SizedBox(height: 12),
        _DetailsCard(
          email: p.email,
          weight: weightDisplay,
          lastActive: p.lastActivity,
          nextSession: p.nextSession,
        ),
      ],
    );
  }

  List<Widget> _buildOverviewAlerts(Trainee p) {
    if (p.alerts.isEmpty) return [];

    final banners = <Widget>[];
    for (final code in p.alerts) {
      final w = _overviewAlertForCode(code);
      if (w != null) {
        if (banners.isNotEmpty) banners.add(const SizedBox(height: 10));
        banners.add(w);
      }
    }
    if (banners.isEmpty) return [];
    return [const SizedBox(height: 16), ...banners];
  }

  Widget? _overviewAlertForCode(String code) {
    switch (code) {
      case 'missed':
        return const _OverviewAlertBanner(
          background: Color(0xFFFFE4E6),
          borderColor: Color(0xFFFECDD3),
          iconBg: Color(0xFFFFCCD0),
          icon: Icons.fitness_center,
          iconColor: Color(0xFFDC2626),
          message: 'Missed workouts',
          messageColor: Color(0xFFB91C1C),
        );
      case 'nutrition':
        return const _OverviewAlertBanner(
          background: Color(0xFFFEF9C3),
          borderColor: Color(0xFFFEF08A),
          iconBg: Color(0xFFFEF08A),
          icon: Icons.eco_outlined,
          iconColor: Color(0xFFD97706),
          message: 'Low nutrition adherence',
          messageColor: Color(0xFFB45309),
        );
      case 'plateau':
        return const _OverviewAlertBanner(
          background: Color(0xFFEDE9FE),
          borderColor: Color(0xFFC4B5FD),
          iconBg: Color(0xFFDDD6FE),
          icon: Icons.show_chart_rounded,
          iconColor: Color(0xFF7C3AED),
          message: 'Weight plateau (3+ weeks)',
          messageColor: Color(0xFF5B21B6),
        );
      default:
        return null;
    }
  }

}

class _SegmentedTabs extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Overview', 'Plans', 'Progress', 'Settings'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == activeIndex;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OverviewMetricTile extends StatelessWidget {
  final String value;
  final Color valueColor;
  final String label;

  const _OverviewMetricTile({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewAlertBanner extends StatelessWidget {
  final Color background;
  final Color borderColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String message;
  final Color messageColor;

  const _OverviewAlertBanner({
    required this.background,
    required this.borderColor,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: messageColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final int workoutDone;
  final int workoutTotal;
  final int workoutPct;
  final int nutritionDone;
  final int nutritionTotal;
  final int nutritionPct;

  const _WeeklySummaryCard({
    required this.workoutDone,
    required this.workoutTotal,
    required this.workoutPct,
    required this.nutritionDone,
    required this.nutritionTotal,
    required this.nutritionPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Workouts',
            done: workoutDone,
            total: workoutTotal,
            pct: workoutPct,
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Nutrition',
            done: nutritionDone,
            total: nutritionTotal,
            pct: nutritionPct,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final int pct;

  const _SummaryRow({
    required this.label,
    required this.done,
    required this.total,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final valueColor = pct >= 70 ? AppColors.textPrimary : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$done/$total ($pct%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 70 ? AppColors.primary : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String email;
  final String weight;
  final String lastActive;
  final String nextSession;

  const _DetailsCard({
    required this.email,
    required this.weight,
    required this.lastActive,
    required this.nextSession,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Email', email),
      ('Weight', weight),
      ('Last Active', lastActive),
      ('Next Session', nextSession),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          e.value.$1,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value.$2,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}
