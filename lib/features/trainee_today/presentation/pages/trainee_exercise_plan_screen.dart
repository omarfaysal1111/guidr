// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_exercise_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import 'package:guidr/features/trainee_today/data/trainee_completed_plan_sessions_storage.dart';
import 'trainee_workout_runner_screen.dart';

class TraineeExercisePlanScreen extends StatefulWidget {
  final ExercisePlan plan;

  const TraineeExercisePlanScreen({super.key, required this.plan});

  @override
  State<TraineeExercisePlanScreen> createState() =>
      _TraineeExercisePlanScreenState();
}

class _TraineeExercisePlanScreenState extends State<TraineeExercisePlanScreen> {
  late final TraineeAppRepository _repository;
  late final TraineeCompletedPlanSessionsStorage _completedLocal;
  TraineeExercisePlanDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = di.sl<TraineeAppRepository>();
    _completedLocal = di.sl<TraineeCompletedPlanSessionsStorage>();
    _loadDetail();
  }

  Future<void> _loadDetail({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }
    try {
      final detail = await _repository.getExercisePlanDetail(widget.plan.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        if (!silent) _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  bool _sessionGroupDone(
    TraineePlanSessionGroup group,
    TraineeExercisePlanDetail plan,
    Set<String> localCompletedPlanSessionIds,
  ) {
    final resolved = traineeResolvedPlanSessionId(group.sessionId, plan);
    if (resolved.isNotEmpty) {
      if (localCompletedPlanSessionIds.contains(resolved)) return true;
      final backend = plan.sessionCompletionBySessionId[resolved];
      if (backend == true) return true;
      if (backend == false) return false;
    }
    return group.exercises.isNotEmpty &&
        group.exercises
            .every((e) => traineeExerciseStatusIndicatesDone(e.status));
  }

  int _remainingSessionCount(
    List<TraineePlanSessionGroup> groups,
    TraineeExercisePlanDetail plan,
    Set<String> localCompletedPlanSessionIds,
  ) {
    var n = 0;
    for (final g in groups) {
      if (!_sessionGroupDone(g, plan, localCompletedPlanSessionIds)) n++;
    }
    return n;
  }

  void _startSession(TraineeExercisePlanDetail plan, String bucketSessionId) {
    final slice = plan.sliceForSessionBucket(bucketSessionId);
    final sid = slice.planSessionId;
    if (sid == null || sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This session cannot be started (missing session id from server).',
          ),
        ),
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => TraineeWorkoutRunnerScreen(detail: slice),
      ),
    ).then((_) {
      if (mounted) _loadDetail(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final localDoneIds = detail != null
        ? _completedLocal.readCompletedPlanSessionIdsThisWeekSync(detail.id)
        : <String>{};
    final groups =
        detail != null ? buildTraineePlanSessionGroups(detail) : <TraineePlanSessionGroup>[];
    final remaining = detail != null
        ? _remainingSessionCount(groups, detail, localDoneIds)
        : 0;

    // Difficulty badge colors
    Color difficultyBg;
    Color difficultyFg;
    final d = detail?.difficulty.toLowerCase() ?? '';
    if (d == 'easy') {
      difficultyBg = AppColors.successLight;
      difficultyFg = AppColors.success;
    } else if (d == 'hard') {
      difficultyBg = AppColors.errorLight;
      difficultyFg = AppColors.error;
    } else {
      difficultyBg = AppColors.warningLight;
      difficultyFg = AppColors.warning;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          detail?.title ?? widget.plan.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (detail != null && detail.difficulty.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: difficultyBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _capitalize(detail.difficulty),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: difficultyFg,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadDetail(silent: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                    if (detail != null) ...[
                      // Overview card with green gradient and decorative circle
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF34D399), Color(0xFF2BC48A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pick any day to train. Finished sessions stay done; you can complete the rest in any order. When your coach or schedule starts a new week, everything opens up again.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatBlock(
                                        label: 'Sessions',
                                        value: '${groups.length}',
                                        icon: Icons.calendar_view_week,
                                      ),
                                      _StatBlock(
                                        label: 'Exercises',
                                        value: '${detail.exercises.length}',
                                        icon: Icons.fitness_center,
                                      ),
                                      _StatBlock(
                                        label: 'Duration',
                                        value: '~${detail.durationMinutes} min',
                                        icon: Icons.timer_outlined,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (detail.coachNote.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Coach's Note",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      detail.coachNote,
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
                        ),
                      if (detail.coachNote.isNotEmpty)
                        const SizedBox(height: 20),

                      const Text(
                        'Sessions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remaining == 0
                            ? 'All sessions completed — great work.'
                            : remaining == groups.length
                                ? 'Tap any session below to start.'
                                : '$remaining session${remaining == 1 ? '' : 's'} left — tap any unfinished one.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...groups.asMap().entries.map((entry) {
                        final i = entry.key;
                        final g = entry.value;
                        final done =
                            _sessionGroupDone(g, detail, localDoneIds);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanSessionCard(
                            group: g,
                            index: i,
                            done: done,
                            onStart: () => _startSession(detail, g.sessionId),
                          ),
                        );
                      }),
                    ] else ...[
                      const Text(
                        'Unable to load workout details.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                  ),
                ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _PlanSessionCard extends StatelessWidget {
  final TraineePlanSessionGroup group;
  final int index;
  final bool done;
  final VoidCallback onStart;

  const _PlanSessionCard({
    required this.group,
    required this.index,
    required this.done,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final preview = group.exercises.take(4).map((e) => e.name).join(' · ');
    final more = group.exercises.length > 4
        ? ' · +${group.exercises.length - 4} more'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
              : AppColors.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFFD1FAE5)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Color(0xFF059669), size: 22)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  if (done)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.exercises.length} exercises',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (done)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '$preview$more',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (done)
            const SizedBox.shrink()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start session',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
