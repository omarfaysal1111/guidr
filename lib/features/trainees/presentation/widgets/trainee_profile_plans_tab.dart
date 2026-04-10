import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import '../../domain/entities/coach_trainee_plans_data.dart';
import '../../domain/entities/coach_trainee_workout_sessions.dart';

const _kWorkoutDayShortLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _assignedDateLabel(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return 'Assigned ${months[d.month - 1]} ${d.day}';
}

String _formatMdY(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

DateTime? _tryParseLooseDate(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  final iso = DateTime.tryParse(t);
  if (iso != null) return iso;
  final parts = t.split(RegExp(r'[/\-.]'));
  if (parts.length == 3) {
    final a = int.tryParse(parts[0].trim());
    final b = int.tryParse(parts[1].trim());
    var y = int.tryParse(parts[2].trim());
    if (a != null && b != null && y != null) {
      if (y < 100) y += 2000;
      if (y <= 1000) return null;
      if (b > 12) return DateTime(y, a, b);
      if (a > 12) return DateTime(y, b, a);
      return DateTime(y, b, a);
    }
  }
  return null;
}

/// Start/end of the week shown in the workout section (for date chips).
(DateTime, DateTime) _workoutWeekBounds(CoachTraineeDetail d) {
  final label = d.workoutWeekRangeLabel?.trim();
  if (label != null && label.toLowerCase().contains(' to ')) {
    final parts = label.split(RegExp(r'\s+to\s+', caseSensitive: false));
    if (parts.length == 2) {
      final a = _tryParseLooseDate(parts[0]);
      final b = _tryParseLooseDate(parts[1]);
      if (a != null && b != null) {
        return a.isBefore(b) ? (a, b) : (b, a);
      }
    }
  }
  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final mon = day.subtract(Duration(days: now.weekday - 1));
  final sun = mon.add(const Duration(days: 6));
  return (mon, sun);
}

/// Plans tab: workout + nutrition week strips, workout plan list (data from coach trainee API).
class TraineeProfilePlansTab extends StatefulWidget {
  final CoachTraineeDetail? detail;
  final bool loading;

  const TraineeProfilePlansTab({
    super.key,
    required this.detail,
    required this.loading,
  });

  @override
  State<TraineeProfilePlansTab> createState() => _TraineeProfilePlansTabState();
}

class _TraineeProfilePlansTabState extends State<TraineeProfilePlansTab> {
  bool _workoutExpanded = true;
  bool _nutritionExpanded = true;
  /// Weekdays (1–7) with expanded day-detail cards; today open by default.
  late Set<int> _openWorkoutDayCards;

  @override
  void initState() {
    super.initState();
    _openWorkoutDayCards = {DateTime.now().weekday};
  }

  @override
  void didUpdateWidget(covariant TraineeProfilePlansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.detail?.profile.id;
    final newId = widget.detail?.profile.id;
    if (oldId != newId) {
      _openWorkoutDayCards = {DateTime.now().weekday};
    }
  }

  void _toggleWorkoutDayCard(int weekday) {
    setState(() {
      if (_openWorkoutDayCards.contains(weekday)) {
        _openWorkoutDayCards = Set.from(_openWorkoutDayCards)..remove(weekday);
      } else {
        _openWorkoutDayCards = Set.from(_openWorkoutDayCards)..add(weekday);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && widget.detail == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final d = widget.detail;
    if (d == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load plans. Pull to refresh or try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final wp = d.workoutProgress;
    final np = d.nutritionProgress;
    final workoutWeekMon = _workoutWeekBounds(d).$1;
    final workoutPeriod = wp.countsForToday ? 'today' : 'this week';
    final nutritionPeriod = np.countsForToday ? 'today' : 'this week';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _ProgressCard(
          expanded: _workoutExpanded,
          onToggle: () => setState(() => _workoutExpanded = !_workoutExpanded),
          icon: Icons.fitness_center_rounded,
          title: 'Workout Progress',
          subtitle:
              '${wp.completedThisWeek}/${wp.targetThisWeek} $workoutPeriod · ${wp.adherencePercent}% adherence',
          showTraineeBadge: wp.dataFromTrainee,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _workoutWeekRowSummary(d.mergedWorkoutWeek),
              const SizedBox(height: 14),
              _WorkoutWeekDateRangeRow(bounds: _workoutWeekBounds(d)),
              if ((d.traineeNoteOnPlan ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _TraineePlanNoteCard(text: d.traineeNoteOnPlan!.trim()),
              ],
              const SizedBox(height: 12),
              ...d.mergedWorkoutWeek.map(
                (session) {
                  final dayDate = DateTime(
                    workoutWeekMon.year,
                    workoutWeekMon.month,
                    workoutWeekMon.day,
                  ).add(Duration(days: session.weekday - 1));
                  final fromCompletion =
                      d.completionExercisesForCalendarDay(dayDate);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ExpandableWorkoutDayCard(
                      session: session,
                      completionExercises: fromCompletion.isNotEmpty
                          ? fromCompletion
                          : null,
                      expanded: _openWorkoutDayCards.contains(session.weekday),
                      onToggle: () => _toggleWorkoutDayCard(session.weekday),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'WORKOUT PLANS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 10),
        ...d.workoutPlans.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WorkoutPlanTile(plan: p),
            )),
        if (d.workoutPlans.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'No workout plans yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        const SizedBox(height: 6),
        _NewWorkoutPlanButton(onTap: () {}),
        const SizedBox(height: 20),
        _ProgressCard(
          expanded: _nutritionExpanded,
          onToggle: () => setState(() => _nutritionExpanded = !_nutritionExpanded),
          icon: Icons.restaurant_menu_rounded,
          title: 'Nutrition Progress',
          subtitle:
              '${np.mealsLogged}/${np.mealsTarget} meals $nutritionPeriod · ${np.adherencePercent}% adherence',
          showTraineeBadge: np.dataFromTrainee,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _nutritionWeekRow(np.days),
              if (np.avgWaterLitersPerDay != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 18, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Avg water: '),
                          TextSpan(
                            text: '${np.avgWaterLitersPerDay!.toStringAsFixed(1)} L/day',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _workoutWeekRowSummary(List<CoachTraineeWorkoutDaySession> days) {
    return Row(
      children: days.map((e) {
        final idx = e.weekday - 1;
        final label =
            idx >= 0 && idx < 7 ? _kWorkoutDayShortLabels[idx] : '?';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _WorkoutDayCell(
              label: label,
              visual: e.stripVisual,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _nutritionWeekRow(List<CoachTraineeNutritionDayEntry> days) {
    return Row(
      children: days.map((e) {
        final idx = e.weekday - 1;
        final label =
            idx >= 0 && idx < 7 ? _kWorkoutDayShortLabels[idx] : '?';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _NutritionDayCell(
              label: label,
              logged: e.mealsLogged,
              target: e.mealsTarget,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showTraineeBadge;
  final Widget child;

  const _ProgressCard({
    required this.expanded,
    required this.onToggle,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showTraineeBadge,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(18),
                bottom: Radius.circular(expanded ? 0 : 18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showTraineeBadge)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'From Trainee',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    Icon(
                      expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: child,
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _TraineePlanNoteCard extends StatelessWidget {
  final String text;

  const _TraineePlanNoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 22,
            color: AppColors.success.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trainee Note on Plan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: AppColors.success.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
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

class _WorkoutWeekDateRangeRow extends StatelessWidget {
  final (DateTime, DateTime) bounds;

  const _WorkoutWeekDateRangeRow({required this.bounds});

  @override
  Widget build(BuildContext context) {
    final start = bounds.$1;
    final end = bounds.$2;
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: AppColors.textMuted.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateRangeChip(text: _formatMdY(start)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'to',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted.withValues(alpha: 0.95),
            ),
          ),
        ),
        Expanded(
          child: _DateRangeChip(text: _formatMdY(end)),
        ),
      ],
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final String text;

  const _DateRangeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

(Color, Color, String) _workoutSessionBadgeStyle(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
    case 'DONE':
    case 'COMPLETE':
      return (AppColors.successLight, AppColors.success, 'Completed');
    case 'PARTIAL':
    case 'IN_PROGRESS':
      return (AppColors.warningLight, AppColors.warning, 'Partial');
    case 'MISSED':
    case 'SKIPPED':
    case 'FAILED':
      return (AppColors.errorLight, AppColors.error, 'Missed');
    case 'REST':
    case 'OFF':
      return (AppColors.surface, AppColors.textMuted, 'Rest');
    default:
      return (AppColors.surface, AppColors.textMuted, 'Upcoming');
  }
}

class _ExpandableWorkoutDayCard extends StatelessWidget {
  final CoachTraineeWorkoutDaySession session;
  /// When set (from [CoachTraineeDetail.workoutCompletionHistory]), replaces session exercises.
  final List<CoachTraineeWorkoutExerciseLog>? completionExercises;
  final bool expanded;
  final VoidCallback onToggle;

  const _ExpandableWorkoutDayCard({
    required this.session,
    this.completionExercises,
    required this.expanded,
    required this.onToggle,
  });

  List<CoachTraineeWorkoutExerciseLog> get _exercisesToShow {
    if (completionExercises != null && completionExercises!.isNotEmpty) {
      return completionExercises!;
    }
    return session.exercises;
  }

  @override
  Widget build(BuildContext context) {
    final idx = session.weekday - 1;
    final dayLabel =
        idx >= 0 && idx < 7 ? _kWorkoutDayShortLabels[idx] : '?';
    final status = session.sessionStatus.toUpperCase();
    final (badgeBg, badgeFg, badgeText) = _workoutSessionBadgeStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: Radius.circular(expanded ? 0 : 14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (session.durationMinutes != null)
                      Text(
                        '${session.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (session.durationMinutes != null) const SizedBox(width: 10),
                    Text(
                      '${session.exercisesDone}/${session.exercisesPlanned} ex',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((session.traineeDayNote ?? '').trim().isNotEmpty) ...[
                    Text(
                      session.traineeDayNote!.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.textSecondary.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_exercisesToShow.isEmpty)
                    Text(
                      'No exercise log for this day.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    )
                  else
                    ..._exercisesToShow.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _WorkoutExerciseLogRow(exercise: e),
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _WorkoutExerciseLogRow extends StatelessWidget {
  final CoachTraineeWorkoutExerciseLog exercise;

  const _WorkoutExerciseLogRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final skipped = exercise.isSkipped;
    final partial = !skipped && exercise.isPartial;
    late Color dot;
    if (skipped) {
      dot = AppColors.error;
    } else if (partial) {
      dot = AppColors.warning;
    } else {
      dot = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                exercise.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: skipped ? AppColors.textMuted : AppColors.textPrimary,
                  decoration: skipped ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (!skipped) ...[
              Icon(
                Icons.show_chart_rounded,
                size: 20,
                color: AppColors.success.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
            ],
            if (skipped)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SKIPPED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ),
            if (!skipped) ...[
              Text(
                exercise.setsDisplayLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        if (exercise.setDetails != null && exercise.setDetails!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SETS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                ...exercise.setDetails!.map((s) {
                  final oc = s.outcome.toUpperCase();
                  Color ocColor;
                  if (s.isCompleted) {
                    ocColor = AppColors.success;
                  } else if (s.isMissed) {
                    ocColor = AppColors.warning;
                  } else {
                    ocColor = AppColors.error;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${s.setNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ocColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            oc,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: ocColor,
                            ),
                          ),
                        ),
                        if ((s.reason ?? '').trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.reason!.trim(),
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        if (skipped && (exercise.skipReason ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.error.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "TRAINEE'S REASON",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.error.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.skipReason!.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WorkoutDayCell extends StatelessWidget {
  final String label;
  final CoachTraineeWorkoutDayVisual visual;

  const _WorkoutDayCell({
    required this.label,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late Widget mark;

    switch (visual) {
      case CoachTraineeWorkoutDayVisual.completed:
        bg = AppColors.successLight;
        fg = AppColors.success;
        mark = Icon(Icons.check_rounded, size: 16, color: fg);
        break;
      case CoachTraineeWorkoutDayVisual.partial:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        mark = Icon(Icons.close_rounded, size: 16, color: fg);
        break;
      case CoachTraineeWorkoutDayVisual.missed:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        mark = Icon(Icons.close_rounded, size: 16, color: fg);
        break;
      case CoachTraineeWorkoutDayVisual.rest:
        bg = AppColors.surface;
        fg = AppColors.textMuted;
        mark = Icon(Icons.remove_rounded, size: 14, color: fg);
        break;
      case CoachTraineeWorkoutDayVisual.upcoming:
        bg = AppColors.surface;
        fg = AppColors.textMuted;
        mark = Icon(Icons.radio_button_unchecked, size: 14, color: fg);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          mark,
        ],
      ),
    );
  }
}

class _NutritionDayCell extends StatelessWidget {
  final String label;
  final int? logged;
  final int? target;

  const _NutritionDayCell({
    required this.label,
    required this.logged,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = logged != null && target != null && target! > 0;
    late Color bg;
    late Color fg;
    late String line;

    if (!hasData) {
      bg = AppColors.surface;
      fg = AppColors.textMuted;
      line = '—';
    } else if (logged! >= target!) {
      bg = AppColors.successLight;
      fg = AppColors.success;
      line = '$logged/$target';
    } else if (logged! > 0) {
      bg = AppColors.warningLight;
      fg = AppColors.warning;
      line = '$logged/$target';
    } else {
      bg = AppColors.surface;
      fg = AppColors.textMuted;
      line = '$logged/$target';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            line,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanTile extends StatelessWidget {
  final CoachTraineeWorkoutPlanRow plan;

  const _WorkoutPlanTile({required this.plan});

  @override
  Widget build(BuildContext context) {
    final active = plan.isActive;
    final draft = plan.isDraft;
    final sub = active && plan.assignedAt != null
        ? 'Active · ${_assignedDateLabel(plan.assignedAt!)}'
        : active
            ? 'Active'
            : draft
                ? 'Draft'
                : plan.status;

    final preview = plan.sessionsPreview;
    final exTotal = preview == null
        ? 0
        : preview.fold<int>(0, (a, s) => a + s.exercises.length);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (preview != null && preview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${preview.length} session(s) · $exTotal exercise(s)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.successLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? AppColors.success.withValues(alpha: 0.35)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    active ? 'Active' : draft ? 'Draft' : plan.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (preview != null && preview.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRESCRIBED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...preview.map((session) {
                    final title = session.title ??
                        (session.dayOrder != null
                            ? 'Day ${session.dayOrder! + 1}'
                            : 'Session');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (session.exercises.isEmpty)
                            Text(
                              'No exercise lines in preview.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            )
                          else
                            ...session.exercises.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '· ${e.name} — ${e.sets} sets'
                                      '${(e.reps ?? '').trim().isNotEmpty ? ' · ${e.reps}' : ''}'
                                      '${(e.load ?? '').trim().isNotEmpty ? ' · ${e.load}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewWorkoutPlanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewWorkoutPlanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: const Text(
            '+ New Workout Plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
