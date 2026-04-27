import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/trainee_app/domain/entities/water_intake_day.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import '../../domain/entities/coach_trainee_plans_data.dart';
import '../../domain/entities/coach_trainee_workout_completion_history.dart';
import '../../domain/entities/coach_trainee_meal_completion_history.dart';
import '../../domain/entities/coach_trainee_workout_sessions.dart';
import '../bloc/trainees_bloc.dart';

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

String _calendarDayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatDayHistoryLabel(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${_kWorkoutDayShortLabels[d.weekday - 1]} · ${months[d.month - 1]} ${d.day}, ${d.year}';
}

String _formatTimeOfDay(DateTime? d) {
  if (d == null) return '';
  final hour = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final minute = d.minute.toString().padLeft(2, '0');
  final suffix = d.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

int _exerciseDoneCount(List<CoachTraineeWorkoutExerciseLog> exercises) {
  return exercises.where((e) => e.countsAsExerciseCompleted).length;
}

int _exercisePlannedCount(List<CoachTraineeWorkoutExerciseLog> exercises) {
  return exercises.where((e) => !e.isSkipped).length;
}

String _statusFromExercises(List<CoachTraineeWorkoutExerciseLog> exercises) {
  if (exercises.isEmpty) return 'COMPLETED';
  if (exercises.every((e) => e.countsAsExerciseCompleted)) return 'COMPLETED';
  if (exercises.any((e) => e.hasLoggedSetsWork || e.isSkipped || e.isPartial)) {
    return 'PARTIAL';
  }
  return 'MISSED';
}

class _WorkoutHistoryDayGroup {
  final String dayKey;
  final DateTime day;
  final List<CoachTraineeWorkoutCompletionRecord> records;

  const _WorkoutHistoryDayGroup({
    required this.dayKey,
    required this.day,
    required this.records,
  });

  List<CoachTraineeWorkoutExerciseLog> get exercises => records
      .where((r) => r.hasDetailedLogs && r.exerciseLogs.isNotEmpty)
      .expand((r) => r.exerciseLogs.map((e) => e.toWorkoutExerciseLog()))
      .toList();

  int get exercisesDone => _exerciseDoneCount(exercises);

  int get exercisesPlanned => _exercisePlannedCount(exercises);

  String get sessionStatus => _statusFromExercises(exercises);

  String get metricText {
    if (exercises.isNotEmpty) {
      final planned = exercisesPlanned;
      final done = exercisesDone;
      if (planned > 0) return '$done/$planned ex';
      return '${exercises.length} ex';
    }
    final count = records.length;
    return '$count session${count == 1 ? '' : 's'}';
  }
}

List<_WorkoutHistoryDayGroup> _groupWorkoutHistoryByDay(
  List<CoachTraineeWorkoutCompletionRecord> records,
) {
  final byDay = <String, List<CoachTraineeWorkoutCompletionRecord>>{};
  final dayDates = <String, DateTime>{};

  for (final record in records) {
    final parsedDate = DateTime.tryParse(record.completionDate) ??
        record.completedAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final day = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final key = _calendarDayKey(day);
    byDay.putIfAbsent(key, () => []).add(record);
    dayDates[key] = day;
  }

  final groups = byDay.entries.map((entry) {
    final dayRecords = List<CoachTraineeWorkoutCompletionRecord>.from(entry.value)
      ..sort((a, b) {
        final aTime = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return _WorkoutHistoryDayGroup(
      dayKey: entry.key,
      day: dayDates[entry.key]!,
      records: dayRecords,
    );
  }).toList()
    ..sort((a, b) => b.day.compareTo(a.day));

  return groups;
}

// ─── Meal history helpers ─────────────────────────────────────────────────────

class _MealHistoryDayGroup {
  final String dayKey;
  final DateTime day;
  final List<MealCompletionRecord> records;

  const _MealHistoryDayGroup({
    required this.dayKey,
    required this.day,
    required this.records,
  });

  int get completedCount => records.where((r) => !r.skipped).length;
  int get skippedCount => records.where((r) => r.skipped).length;
  int get totalCount => records.length;

  String get metricText => '$completedCount/$totalCount meals';

  String get dayStatus {
    if (records.isEmpty) return 'MISSED';
    if (records.every((r) => r.skipped)) return 'SKIPPED';
    if (records.every((r) => !r.skipped)) return 'COMPLETED';
    return 'PARTIAL';
  }
}

List<_MealHistoryDayGroup> _groupMealHistoryByDay(
  List<MealCompletionRecord> records,
) {
  final byDay = <String, List<MealCompletionRecord>>{};
  final dayDates = <String, DateTime>{};

  for (final record in records) {
    final parsedDate = DateTime.tryParse(record.completionDate) ??
        record.completedAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final day = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    final key = _calendarDayKey(day);
    byDay.putIfAbsent(key, () => []).add(record);
    dayDates[key] = day;
  }

  return byDay.entries.map((entry) {
    final dayRecords = List<MealCompletionRecord>.from(entry.value)
      ..sort((a, b) {
        final aTime = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return _MealHistoryDayGroup(
      dayKey: entry.key,
      day: dayDates[entry.key]!,
      records: dayRecords,
    );
  }).toList()
    ..sort((a, b) => b.day.compareTo(a.day));
}

// ─────────────────────────────────────────────────────────────────────────────

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

/// Plans tab: goal/level quick-edit, workout + nutrition week strips, workout plan list.
class TraineeProfilePlansTab extends StatefulWidget {
  final CoachTraineeDetail? detail;
  final bool loading;
  final String traineeId;
  final WaterIntakeDay? waterIntake;

  const TraineeProfilePlansTab({
    super.key,
    required this.detail,
    required this.loading,
    required this.traineeId,
    this.waterIntake,
  });

  @override
  State<TraineeProfilePlansTab> createState() => _TraineeProfilePlansTabState();
}

class _TraineeProfilePlansTabState extends State<TraineeProfilePlansTab> {
  bool _workoutExpanded = true;
  bool _nutritionExpanded = true;
  /// Expanded day-detail cards; today open by default.
  late Set<String> _openWorkoutDayCards;
  late Set<String> _openMealDayCards;

  // Goal / level inline editor
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];
  late TextEditingController _goalController;
  late String _editLevel;
  String _savedGoal = '';
  String _savedLevel = '';

  bool get _goalLevelDirty =>
      _goalController.text.trim() != _savedGoal ||
      _editLevel != _savedLevel;

  void _syncGoalLevel() {
    final p = widget.detail?.profile;
    _savedGoal = p?.goal ?? '';
    _savedLevel = _levels.contains(p?.level) ? p!.level : _levels[0];
    _goalController.text = _savedGoal;
    _editLevel = _savedLevel;
  }

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
    _editLevel = _levels[0];
    _syncGoalLevel();
    _goalController.addListener(() => setState(() {}));
    _openWorkoutDayCards = {
      'history:${_calendarDayKey(DateTime.now())}',
      'week:${DateTime.now().weekday}',
    };
    _openMealDayCards = {
      'meal:${_calendarDayKey(DateTime.now())}',
    };
  }

  @override
  void didUpdateWidget(covariant TraineeProfilePlansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.detail?.profile.id;
    final newId = widget.detail?.profile.id;
    if (oldId != newId) {
      _syncGoalLevel();
      _openWorkoutDayCards = {
        'history:${_calendarDayKey(DateTime.now())}',
        'week:${DateTime.now().weekday}',
      };
      _openMealDayCards = {
        'meal:${_calendarDayKey(DateTime.now())}',
      };
    } else if (!_goalLevelDirty) {
      // Refresh saved values if the detail was reloaded (e.g. after a save).
      _syncGoalLevel();
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _toggleWorkoutDayCard(String key) {
    setState(() {
      if (_openWorkoutDayCards.contains(key)) {
        _openWorkoutDayCards = Set.from(_openWorkoutDayCards)..remove(key);
      } else {
        _openWorkoutDayCards = Set.from(_openWorkoutDayCards)..add(key);
      }
    });
  }

  void _toggleMealDayCard(String key) {
    setState(() {
      if (_openMealDayCards.contains(key)) {
        _openMealDayCards = Set.from(_openMealDayCards)..remove(key);
      } else {
        _openMealDayCards = Set.from(_openMealDayCards)..add(key);
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

    return BlocListener<TraineesBloc, TraineesState>(
      listenWhen: (prev, curr) {
        if (prev is! TraineesLoaded || curr is! TraineesLoaded) return false;
        return prev.goalLevelSaving != curr.goalLevelSaving ||
            prev.goalLevelError != curr.goalLevelError;
      },
      listener: (context, state) {
        if (state is! TraineesLoaded) return;
        if (!state.goalLevelSaving && state.goalLevelError == null) {
          // Sync local editor state so the Save button hides after a successful save.
          setState(_syncGoalLevel);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Goal & level saved'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state.goalLevelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.goalLevelError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: BlocBuilder<TraineesBloc, TraineesState>(
        buildWhen: (prev, curr) {
          if (prev is! TraineesLoaded || curr is! TraineesLoaded) return true;
          return prev.goalLevelSaving != curr.goalLevelSaving;
        },
        builder: (context, blocState) {
          final saving = blocState is TraineesLoaded && blocState.goalLevelSaving;
          return _buildList(d, saving);
        },
      ),
    );
  }

  Widget _buildList(CoachTraineeDetail d, bool saving) {
    final wp = d.workoutProgress;
    final np = d.nutritionProgress;
    final historyGroups = _groupWorkoutHistoryByDay(d.workoutCompletionHistory);
    final mealHistoryGroups = _groupMealHistoryByDay(d.mealCompletionHistory);
    final workoutPeriod = wp.countsForToday ? 'today' : 'this week';
    final nutritionPeriod = np.countsForToday ? 'today' : 'this week';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _GoalLevelCard(
          goalController: _goalController,
          selectedLevel: _editLevel,
          levels: _levels,
          isDirty: _goalLevelDirty,
          saving: saving,
          onLevelChanged: (v) => setState(() => _editLevel = v!),
          onSave: () {
            context.read<TraineesBloc>().add(UpdateTraineeGoalLevelEvent(
              traineeId: widget.traineeId,
              goal: _goalController.text.trim(),
              level: _editLevel,
            ));
          },
        ),
        const SizedBox(height: 16),
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
              if (historyGroups.isNotEmpty)
                ...historyGroups.map((group) {
                  final groupSession = CoachTraineeWorkoutDaySession(
                    weekday: group.day.weekday,
                    stripVisual: CoachTraineeWorkoutProgress.visualForStatusString(
                      group.sessionStatus,
                    ),
                    sessionStatus: group.sessionStatus,
                    durationMinutes: null,
                    exercisesDone: group.exercisesDone,
                    exercisesPlanned: group.exercisesPlanned,
                    traineeDayNote: null,
                    exercises: group.exercises,
                  );
                  final cardKey = 'history:${group.dayKey}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ExpandableWorkoutDayCard(
                      session: groupSession,
                      dayLabelOverride: _formatDayHistoryLabel(group.day),
                      metricTextOverride: group.metricText,
                      completionRecords: group.records,
                      allCompletionHistory: d.workoutCompletionHistory,
                      expanded: _openWorkoutDayCards.contains(cardKey),
                      onToggle: () => _toggleWorkoutDayCard(cardKey),
                    ),
                  );
                })
              else
                ...d.mergedWorkoutWeek.map((session) {
                  final cardKey = 'week:${session.weekday}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ExpandableWorkoutDayCard(
                      session: session,
                      allCompletionHistory: d.workoutCompletionHistory,
                      expanded: _openWorkoutDayCards.contains(cardKey),
                      onToggle: () => _toggleWorkoutDayCard(cardKey),
                    ),
                  );
                }),
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
              ...() {
                final w = widget.waterIntake;
                if (w == null) return <Widget>[];
                return <Widget>[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.water_drop, size: 18, color: Color(0xFF0EA5E9)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(
                                text: "Today's total: ",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: '${w.liters.toStringAsFixed(2)} L',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0EA5E9),
                                ),
                              ),
                              if (w.updatedAt != null)
                                TextSpan(
                                  text:
                                      ' · ${DateFormat('MMM d, HH:mm').format(w.updatedAt!.toLocal())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ];
              }(),
              if (mealHistoryGroups.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...mealHistoryGroups.map((group) {
                  final cardKey = 'meal:${group.dayKey}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MealCompletionDayCard(
                      group: group,
                      expanded: _openMealDayCards.contains(cardKey),
                      onToggle: () => _toggleMealDayCard(cardKey),
                    ),
                  );
                }),
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

class _GoalLevelCard extends StatelessWidget {
  final TextEditingController goalController;
  final String selectedLevel;
  final List<String> levels;
  final bool isDirty;
  final bool saving;
  final ValueChanged<String?> onLevelChanged;
  final VoidCallback onSave;

  const _GoalLevelCard({
    required this.goalController,
    required this.selectedLevel,
    required this.levels,
    required this.isDirty,
    required this.saving,
    required this.onLevelChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Goal & Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'TRAINEE LEVEL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedLevel,
            onChanged: onLevelChanged,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            items: levels
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'GOAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: goalController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Lose 5 kg, Build muscle...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(
                Icons.track_changes_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          // Save button appears only when values differ from the saved state.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: isDirty
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(saving ? 'Saving…' : 'Save Changes'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 20),
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
  final List<CoachTraineeWorkoutCompletionRecord>? completionRecords;
  final List<CoachTraineeWorkoutCompletionRecord>? allCompletionHistory;
  final String? dayLabelOverride;
  final String? metricTextOverride;
  final bool expanded;
  final VoidCallback onToggle;

  const _ExpandableWorkoutDayCard({
    required this.session,
    this.completionRecords,
    this.allCompletionHistory,
    this.dayLabelOverride,
    this.metricTextOverride,
    required this.expanded,
    required this.onToggle,
  });

  List<CoachTraineeWorkoutExerciseLog> get _exercisesToShow {
    if (completionRecords != null && completionRecords!.isNotEmpty) {
      return completionRecords!
          .where((r) => r.hasDetailedLogs && r.exerciseLogs.isNotEmpty)
          .expand((r) => r.exerciseLogs.map((e) => e.toWorkoutExerciseLog()))
          .toList();
    }
    return session.exercises;
  }

  String get _metricText {
    if ((metricTextOverride ?? '').trim().isNotEmpty) return metricTextOverride!.trim();
    final exercises = _exercisesToShow;
    final planned = session.exercisesPlanned > 0
        ? session.exercisesPlanned
        : _exercisePlannedCount(exercises);
    final done = session.exercisesDone > 0
        ? session.exercisesDone
        : _exerciseDoneCount(exercises);
    if (planned > 0) return '$done/$planned ex';
    if (exercises.isNotEmpty) return '${exercises.length} ex';
    return '0 ex';
  }

  Widget _buildCompletionRecordBlock(
    BuildContext context,
    CoachTraineeWorkoutCompletionRecord record,
  ) {
    final sessionTitle = (record.planSessionTitle ?? '').trim().isNotEmpty
        ? record.planSessionTitle!.trim()
        : 'Workout session';
    final meta = <String>[];
    final planTitle = (record.workoutPlanTitle ?? '').trim();
    if (planTitle.isNotEmpty) meta.add(planTitle);
    meta.add('Day ${record.dayOrder + 1}');
    final timeText = _formatTimeOfDay(record.completedAt);
    if (timeText.isNotEmpty) meta.add(timeText);
    final exercises = record.exerciseLogs.map((e) => e.toWorkoutExerciseLog()).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sessionTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meta.join(' · '),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withValues(alpha: 0.95),
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (record.hasDetailedLogs && exercises.isNotEmpty)
            ...exercises.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WorkoutExerciseLogRow(
                  exercise: e,
                  allHistory: allCompletionHistory,
                ),
              ),
            )
          else
            Text(
              'This session has no detailed exercise logs.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = session.weekday - 1;
    final dayLabel = (dayLabelOverride ?? '').trim().isNotEmpty
        ? dayLabelOverride!.trim()
        : (idx >= 0 && idx < 7 ? _kWorkoutDayShortLabels[idx] : '?');
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
                      _metricText,
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
                  if (completionRecords != null && completionRecords!.isNotEmpty)
                    ...completionRecords!.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCompletionRecordBlock(context, record),
                      ),
                    )
                  else if (_exercisesToShow.isEmpty)
                    Text(
                      'No exercise log for this day.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    )
                  else
                    ..._exercisesToShow.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _WorkoutExerciseLogRow(
                          exercise: e,
                          allHistory: allCompletionHistory,
                        ),
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
  final List<CoachTraineeWorkoutCompletionRecord>? allHistory;

  const _WorkoutExerciseLogRow({
    required this.exercise,
    this.allHistory,
  });

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
              GestureDetector(
                onTap: allHistory != null && allHistory!.isNotEmpty
                    ? () => _showWeightProgressSheet(context, exercise.name, allHistory!)
                    : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Set',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          'Kg',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Reps',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  final w = s.weightKg;
                  final weightLabel = w == null
                      ? '—'
                      : ((w - w.round()).abs() < 1e-6
                          ? '${w.round()}'
                          : w.toStringAsFixed(1));
                  final repsLabel = s.reps != null ? '${s.reps}' : '—';
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
                        SizedBox(
                          width: 52,
                          child: Text(
                            weightLabel,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 44,
                          child: Text(
                            repsLabel,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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

// ─── Weight Progress Feature ──────────────────────────────────────────────────

class _WeightDataPoint {
  final String sessionLabel;
  final double weightKg;

  const _WeightDataPoint({required this.sessionLabel, required this.weightKg});
}

List<_WeightDataPoint> _extractWeightHistory(
  String exerciseName,
  List<CoachTraineeWorkoutCompletionRecord> history,
) {
  final normalized = exerciseName.trim().toLowerCase();
  final matches = <(DateTime, double)>[];
  for (final record in history) {
    for (final log in record.exerciseLogs) {
      if (log.exerciseName.trim().toLowerCase() != normalized) continue;
      final date = record.completedAt ??
          DateTime.tryParse(record.completionDate) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      // Prefer per-set weights: use max completed-set weight for this exercise row.
      final setWeights = log.setDetails
          .where((s) => s.isCompleted && s.weightKg != null && s.weightKg! > 0)
          .map((s) => s.weightKg!)
          .toList();
      if (setWeights.isNotEmpty) {
        final maxKg = setWeights.reduce((a, b) => a > b ? a : b);
        matches.add((date, maxKg));
      } else if (log.wieghtKg > 0) {
        matches.add((date, log.wieghtKg));
      }
    }
  }
  matches.sort((a, b) => a.$1.compareTo(b.$1));
  return matches.asMap().entries.map((entry) {
    return _WeightDataPoint(
      sessionLabel: 'W${entry.key + 1}',
      weightKg: entry.value.$2,
    );
  }).toList();
}

void _showWeightProgressSheet(
  BuildContext context,
  String exerciseName,
  List<CoachTraineeWorkoutCompletionRecord> history,
) {
  final dataPoints = _extractWeightHistory(exerciseName, history);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WeightProgressSheet(
      exerciseName: exerciseName,
      dataPoints: dataPoints,
    ),
  );
}

class _WeightProgressSheet extends StatelessWidget {
  final String exerciseName;
  final List<_WeightDataPoint> dataPoints;

  const _WeightProgressSheet({
    required this.exerciseName,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = dataPoints.isNotEmpty;
    final currentKg = hasData ? dataPoints.last.weightKg : 0.0;
    final firstKg = hasData ? dataPoints.first.weightKg : 0.0;
    final changeKg = currentKg - firstKg;
    final sessions = dataPoints.length;

    String summaryText;
    if (!hasData) {
      summaryText = 'No weight data recorded yet';
    } else if (sessions == 1) {
      summaryText = 'Weight recorded in 1 session';
    } else if (changeKg > 0) {
      summaryText =
          'Weight increased by ${_formatKg(changeKg)} kg over $sessions sessions';
    } else if (changeKg < 0) {
      summaryText =
          'Weight decreased by ${_formatKg(-changeKg)} kg over $sessions sessions';
    } else {
      summaryText = 'Weight unchanged over $sessions sessions';
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Weight Progress Over Sessions',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hasData)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _WeightStatCard(
                      label: 'Current',
                      value: '${_formatKg(currentKg)} kg',
                      valueColor: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WeightStatCard(
                      label: 'Change',
                      value: '${changeKg >= 0 ? '+' : ''}${_formatKg(changeKg)} kg',
                      valueColor: changeKg > 0
                          ? AppColors.success
                          : changeKg < 0
                              ? AppColors.error
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (hasData && dataPoints.length >= 2) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeightLineChart(dataPoints: dataPoints),
            ),
            const SizedBox(height: 16),
          ] else if (hasData) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Record more sessions to see the progress trend.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              summaryText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

String _formatKg(double kg) {
  if (kg == kg.roundToDouble()) return kg.round().toString();
  return kg.toStringAsFixed(1);
}

class _WeightStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _WeightStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightLineChart extends StatefulWidget {
  final List<_WeightDataPoint> dataPoints;

  const _WeightLineChart({required this.dataPoints});

  @override
  State<_WeightLineChart> createState() => _WeightLineChartState();
}

class _WeightLineChartState extends State<_WeightLineChart> {
  int? _selectedIndex;

  void _handleTouch(Offset localPos, Size chartSize) {
    final n = widget.dataPoints.length;
    if (n == 0) return;
    const hPad = 12.0;
    final usableW = chartSize.width - hPad * 2;
    int closest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < n; i++) {
      final x = hPad + (n == 1 ? usableW / 2 : usableW * i / (n - 1));
      final dist = (localPos.dx - x).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = i;
      }
    }
    setState(() => _selectedIndex = closest);
  }

  void _clearTouch() => setState(() => _selectedIndex = null);

  @override
  Widget build(BuildContext context) {
    final weights = widget.dataPoints.map((p) => p.weightKg).toList();
    final labels = widget.dataPoints.map((p) => p.sessionLabel).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTapDown: (d) {
            _handleTouch(d.localPosition, Size(MediaQuery.of(context).size.width - 40, 140));
          },
          onPanUpdate: (d) {
            _handleTouch(d.localPosition, Size(MediaQuery.of(context).size.width - 40, 140));
          },
          onPanEnd: (_) => _clearTouch(),
          onTapUp: (_) {}, // keep tooltip on tap (don't clear)
          child: SizedBox(
            height: 140,
            child: LayoutBuilder(
              builder: (_, constraints) => CustomPaint(
                size: Size(constraints.maxWidth, 140),
                painter: _WeightLinePainter(
                  weights: weights,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: labels.asMap().entries.map((e) {
            final isSelected = _selectedIndex == e.key;
            return Expanded(
              child: Text(
                e.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                  color: isSelected ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _WeightLinePainter extends CustomPainter {
  final List<double> weights;
  final int? selectedIndex;

  const _WeightLinePainter({required this.weights, this.selectedIndex});

  static const _lineColor = AppColors.success;
  static const _topPad = 28.0;
  static const _hPad = 12.0;

  List<Offset> _buildPoints(Size size) {
    final n = weights.length;
    final chartH = size.height - _topPad - 4;
    final usableW = size.width - _hPad * 2;
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).abs();
    return List.generate(n, (i) {
      final x = _hPad + (n == 1 ? usableW / 2 : usableW * i / (n - 1));
      final y = _topPad + (range > 0 ? chartH * (1 - (weights[i] - minW) / range) : chartH * 0.5);
      return Offset(x, y);
    });
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }
    const tension = 0.35;
    for (int i = 0; i < pts.length - 1; i++) {
      final prev = i > 0 ? pts[i - 1] : pts[i];
      final curr = pts[i];
      final next = pts[i + 1];
      final after = i < pts.length - 2 ? pts[i + 2] : pts[i + 1];
      final cp1 = Offset(
        curr.dx + (next.dx - prev.dx) * tension,
        curr.dy + (next.dy - prev.dy) * tension,
      );
      final cp2 = Offset(
        next.dx - (after.dx - curr.dx) * tension,
        next.dy - (after.dy - curr.dy) * tension,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;
    final pts = _buildPoints(size);
    final bottomY = size.height - 4;

    // Gradient fill under curve
    final curvePath = _smoothPath(pts);
    final fillPath = Path.from(curvePath)
      ..lineTo(pts.last.dx, bottomY)
      ..lineTo(pts.first.dx, bottomY)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lineColor.withValues(alpha: 0.20),
            _lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, _topPad, size.width, size.height - _topPad)),
    );

    // Smooth line
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = _lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Last-point label (always shown, hidden when another point is selected)
    if (selectedIndex == null || selectedIndex == pts.length - 1) {
      _drawLabel(canvas, pts.last, '${_formatKg(weights.last)}kg', size);
    }

    // Dots (small for unselected, large for selected)
    for (int i = 0; i < pts.length; i++) {
      final isSelected = selectedIndex == i;
      if (isSelected) {
        // Outer ring
        canvas.drawCircle(pts[i], 9,
            Paint()..color = _lineColor.withValues(alpha: 0.18)..style = PaintingStyle.fill);
        // Filled dot
        canvas.drawCircle(pts[i], 5,
            Paint()..color = _lineColor..style = PaintingStyle.fill);
        // White inner
        canvas.drawCircle(pts[i], 2.5,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        // Tooltip
        _drawTooltip(canvas, pts[i], '${_formatKg(weights[i])}kg', size);
      } else {
        // White ring + filled dot
        canvas.drawCircle(pts[i], 4.5,
            Paint()..color = Colors.white..style = PaintingStyle.fill);
        canvas.drawCircle(pts[i], 3.5,
            Paint()..color = _lineColor..style = PaintingStyle.fill);
      }
    }
  }

  void _drawLabel(Canvas canvas, Offset pt, String text, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _lineColor,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final dx = (pt.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
    tp.paint(canvas, Offset(dx, pt.dy - tp.height - 8));
  }

  void _drawTooltip(Canvas canvas, Offset pt, String text, Size size) {
    const hPadding = 10.0;
    const vPadding = 5.0;
    const radius = 8.0;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final tooltipW = tp.width + hPadding * 2;
    final tooltipH = tp.height + vPadding * 2;
    const arrowH = 5.0;
    final totalH = tooltipH + arrowH;

    double left = pt.dx - tooltipW / 2;
    left = left.clamp(0.0, size.width - tooltipW);
    final top = pt.dy - totalH - 6;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, tooltipW, tooltipH),
      const Radius.circular(radius),
    );
    canvas.drawRRect(bgRect, Paint()..color = _lineColor);

    // Arrow
    final arrowPath = Path()
      ..moveTo(pt.dx - 5, top + tooltipH)
      ..lineTo(pt.dx, top + tooltipH + arrowH)
      ..lineTo(pt.dx + 5, top + tooltipH)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = _lineColor);

    tp.paint(canvas, Offset(left + hPadding, top + vPadding));
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter old) =>
      old.weights != weights || old.selectedIndex != selectedIndex;
}

// ─── Meal Completion History Widgets ─────────────────────────────────────────

(Color, Color, String) _mealDayBadgeStyle(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return (AppColors.successLight, AppColors.success, 'Completed');
    case 'PARTIAL':
      return (AppColors.warningLight, AppColors.warning, 'Partial');
    case 'SKIPPED':
      return (AppColors.errorLight, AppColors.error, 'Skipped');
    default:
      return (AppColors.surface, AppColors.textMuted, 'Logged');
  }
}

class _MealCompletionDayCard extends StatelessWidget {
  final _MealHistoryDayGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  const _MealCompletionDayCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, badgeText) = _mealDayBadgeStyle(group.dayStatus);
    final dayLabel = _formatDayHistoryLabel(group.day);

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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                    Text(
                      group.metricText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
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
                children: group.records
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MealCompletionRecordBlock(record: r),
                        ))
                    .toList(),
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

class _MealCompletionRecordBlock extends StatelessWidget {
  final MealCompletionRecord record;

  const _MealCompletionRecordBlock({required this.record});

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTimeOfDay(record.completedAt);
    final meta = <String>[];
    if ((record.nutritionPlanTitle).trim().isNotEmpty) {
      meta.add(record.nutritionPlanTitle.trim());
    }
    if (timeText.isNotEmpty) meta.add(timeText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.mealName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: record.skipped
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: record.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta.join(' · '),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: record.skipped
                      ? AppColors.errorLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.skipped ? 'SKIPPED' : 'DONE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: record.skipped
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          if (record.hasDeviations &&
              record.ingredientDeviations.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'INGREDIENT CHANGES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 6),
            ...record.ingredientDeviations
                .map((dev) => _MealDeviationRow(deviation: dev)),
          ],
        ],
      ),
    );
  }
}

class _MealDeviationRow extends StatelessWidget {
  final MealIngredientDeviation deviation;

  const _MealDeviationRow({required this.deviation});

  @override
  Widget build(BuildContext context) {
    final isSkipped = deviation.isSkipped;
    final dotColor = isSkipped ? AppColors.error : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviation.originalIngredientName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    decoration: isSkipped ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!isSkipped &&
                    (deviation.replacementIngredientName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz,
                          size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deviation.replacementIngredientName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (deviation.newQuantity != null)
                        Text(
                          '${deviation.newQuantity!.toStringAsFixed(0)}g',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ] else if (isSkipped)
                  Text(
                    'Skipped',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.error.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isSkipped ? 'SKIPPED' : 'SWAPPED',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: dotColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
