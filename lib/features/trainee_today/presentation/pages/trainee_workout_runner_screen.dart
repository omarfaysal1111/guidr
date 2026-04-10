import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainee_app/domain/entities/complete_workout_request.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_exercise_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import 'package:guidr/features/trainee_app/domain/validators/complete_workout_validator.dart';
import 'package:guidr/features/trainee_today/data/trainee_completed_plan_sessions_storage.dart';
import 'trainee_workout_complete_screen.dart';

class TraineeWorkoutRunnerScreen extends StatefulWidget {
  final TraineeExercisePlanDetail detail;

  const TraineeWorkoutRunnerScreen({super.key, required this.detail});

  @override
  State<TraineeWorkoutRunnerScreen> createState() =>
      _TraineeWorkoutRunnerScreenState();
}

class _TraineeWorkoutRunnerScreenState
    extends State<TraineeWorkoutRunnerScreen> {
  late final TraineeAppRepository _repository;
  late final TraineeCompletedPlanSessionsStorage _completedLocal;
  int _currentExerciseIndex = 0;
  late final List<List<_RunnerSetLog>> _setLogs;
  String _weightText = '60 kg';
  final DateTime _startTime = DateTime.now();
  bool _finishing = false;

  int _loggedFor(int exerciseIndex) => _setLogs[exerciseIndex].length;

  int _completedFor(int exerciseIndex) =>
      _setLogs[exerciseIndex].where((e) => e.isCompleted).length;

  int _skippedFor(int exerciseIndex) => _setLogs[exerciseIndex]
      .where((e) => e.outcome == SetLogOutcome.skipped)
      .length;

  int _missedFor(int exerciseIndex) =>
      _setLogs[exerciseIndex].where((e) => e.outcome == SetLogOutcome.missed).length;

  @override
  void initState() {
    super.initState();
    _repository = di.sl<TraineeAppRepository>();
    _completedLocal = di.sl<TraineeCompletedPlanSessionsStorage>();
    _setLogs = List.generate(
      widget.detail.exercises.length,
      (_) => <_RunnerSetLog>[],
    );
    if (widget.detail.exercises.isNotEmpty) {
      _weightText = widget.detail.exercises.first.load ?? '60 kg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.detail.exercises;
    final totalSets =
        exercises.fold<int>(0, (sum, e) => sum + (e.sets > 0 ? e.sets : 0));
    final completedSets = exercises.asMap().entries.fold<int>(
        0, (sum, e) => sum + _loggedFor(e.key));

    final current = exercises[_currentExerciseIndex];
    final currentCompleted = _loggedFor(_currentExerciseIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            // Header timer + sets summary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.textPrimary),
                    onPressed:
                        _finishing ? null : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'WORKOUT TIME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '00:03',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.pause,
                            color: AppColors.textPrimary),
                        onPressed: () {},
                      ),
                      Text(
                        '$completedSets/$totalSets sets',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Progress bar under header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: totalSets == 0 ? 0 : completedSets / totalSets,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrentExerciseCard(
                      context,
                      current,
                      currentCompleted,
                      totalSets: totalSets,
                      completedSets: completedSets,
                    ),
                    const SizedBox(height: 24),
                    _buildAllExercisesList(exercises),
                    const SizedBox(height: 24),
                    _buildWorkoutNotes(),
                  ],
                ),
              ),
            ),
              ],
            ),
            if (_finishing)
              Positioned.fill(
                child: AbsorbPointer(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Saving session…'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentExerciseCard(
    BuildContext context,
    TraineeExerciseItem current,
    int currentCompleted, {
    required int totalSets,
    required int completedSets,
  }) {
    final exerciseNumber = _currentExerciseIndex + 1;
    final totalExercises = widget.detail.exercises.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / image placeholder + muscle group
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.play_circle_filled,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  onPressed: () {
                    if ((current.videoUrl ?? '').isEmpty) return;
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Exercise Video Preview',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Open video: ${current.videoUrl}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  current.muscleGroup,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'EXERCISE $exerciseNumber OF $totalExercises',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              current.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${current.sets} × ${current.reps}'
              '${current.load != null && current.load!.isNotEmpty ? ' at ${current.load}' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Set buttons
            Row(
              children: List.generate(current.sets, (index) {
                final setNumber = index + 1;
                final isDone = setNumber <= currentCompleted;
                final isActive = setNumber == currentCompleted + 1;
                Color bg;
                Color fg;
                if (isDone) {
                  bg = AppColors.primary;
                  fg = Colors.white;
                } else if (isActive) {
                  bg = Colors.white;
                  fg = AppColors.primary;
                } else {
                  bg = AppColors.surface;
                  fg = AppColors.textSecondary;
                }
                return Padding(
                  padding: EdgeInsets.only(right: index == current.sets - 1 ? 0 : 8),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      side: BorderSide(
                        color: isDone
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      backgroundColor: bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Set $setNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            // Simple notes + controls (static text for now)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Focus on depth — full ROM today',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Keep chest up, don’t round lower back',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    _showSkipSetSheet(context, current);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Skip or miss',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _markSetCompleted(
                        current,
                        outcome: SetLogOutcome.completed,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Complete Set ${currentCompleted + 1 > current.sets ? current.sets : currentCompleted + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await _skipEntireExercise(current);
              },
              child: const Text(
                'Skip Entire Exercise',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Weight row
            Row(
              children: [
                const Text(
                  'Weight:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _weightText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllExercisesList(List<TraineeExerciseItem> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALL EXERCISES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(exercises.length, (index) {
          final e = exercises[index];
          final completed = _loggedFor(index);
          final done = _completedFor(index);
          final skipped = _skippedFor(index);
          final missed = _missedFor(index);
          final isCurrent = index == _currentExerciseIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentExerciseIndex = index;
                _weightText = e.load ?? _weightText;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? AppColors.primary : AppColors.border,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          e.sets <= 0
                              ? '—'
                              : (skipped > 0 || missed > 0)
                                  ? '$completed/${e.sets} sets · $done done'
                                      '${skipped > 0 ? ', $skipped skipped' : ''}'
                                      '${missed > 0 ? ', $missed missed' : ''}'
                                  : '$completed/${e.sets} sets',
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
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWorkoutNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORKOUT NOTES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How are you feeling? Any adjustments?',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markSetCompleted(
    TraineeExerciseItem current, {
    required SetLogOutcome outcome,
    String? reason,
  }) async {
    final i = _currentExerciseIndex;
    final logged = _loggedFor(i);
    if (logged >= current.sets) {
      await _advanceToNextOrFinish();
      return;
    }

    setState(() {
      switch (outcome) {
        case SetLogOutcome.completed:
          _setLogs[i].add(_RunnerSetLog.completed());
        case SetLogOutcome.skipped:
          _setLogs[i].add(_RunnerSetLog.skipped(reason));
        case SetLogOutcome.missed:
          _setLogs[i].add(_RunnerSetLog.missed(reason));
      }
    });

    final newTotal = _loggedFor(i);
    if (newTotal >= current.sets) {
      await _advanceToNextOrFinish();
    }
  }

  Future<void> _skipEntireExercise(TraineeExerciseItem current) async {
    final i = _currentExerciseIndex;
    final planned = current.sets;
    if (planned <= 0) {
      await _advanceToNextOrFinish();
      return;
    }

    setState(() {
      var next = _loggedFor(i);
      while (next < planned) {
        next++;
        _setLogs[i]
            .add(_RunnerSetLog.skipped('Entire exercise skipped'));
      }
    });
    await _advanceToNextOrFinish();
  }

  Future<void> _advanceToNextOrFinish() async {
    final exercises = widget.detail.exercises;
    final totalSets =
        exercises.fold<int>(0, (sum, e) => sum + (e.sets > 0 ? e.sets : 0));
    final loggedAllSets = exercises.asMap().entries.fold<int>(
        0, (sum, e) => sum + _loggedFor(e.key));

    if (loggedAllSets >= totalSets) {
      await _finishWorkout();
    } else if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _weightText = exercises[_currentExerciseIndex].load ?? _weightText;
      });
    }
  }

  Map<String, int> _plannedSetsByLineId() {
    final m = <String, int>{};
    for (final e in widget.detail.exercises) {
      final id = e.id.trim();
      if (id.isEmpty) continue;
      m[id] = e.sets;
    }
    return m;
  }

  CompleteWorkoutRequest _buildCompleteWorkoutRequest() {
    final logs = <ExerciseLogItemRequest>[];
    for (var i = 0; i < widget.detail.exercises.length; i++) {
      final ex = widget.detail.exercises[i];
      if (ex.sets <= 0) continue;
      final row = <ExerciseSetLogRequest>[];
      for (final entry in _setLogs[i]) {
        if (entry.outcome == SetLogOutcome.completed) {
          row.add(const ExerciseSetLogRequest(outcome: SetLogOutcome.completed));
        } else {
          final r = (entry.reason ?? '').trim();
          row.add(ExerciseSetLogRequest(
            outcome: entry.outcome,
            reason: r.isEmpty ? 'No reason provided' : r,
          ));
        }
      }
      logs.add(ExerciseLogItemRequest(
        planSessionExerciseId: ex.id.trim(),
        setOutcomes: row,
      ));
    }
    return CompleteWorkoutRequest(exerciseLogs: logs);
  }

  Future<void> _finishWorkout() async {
    final exercises = widget.detail.exercises;
    final planSessionId = widget.detail.planSessionId;
    if (planSessionId == null || planSessionId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This plan cannot be completed from the app (missing session id).',
            ),
          ),
        );
      }
      return;
    }

    for (final ex in exercises) {
      if (ex.sets > 0 && ex.id.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot submit: an exercise is missing planSessionExerciseId.',
              ),
            ),
          );
        }
        return;
      }
    }

    final request = _buildCompleteWorkoutRequest();
    if (request.exerciseLogs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No exercises with prescribed sets to submit.'),
          ),
        );
      }
      return;
    }

    final validationError = CompleteWorkoutValidator.validate(
      request: request,
      plannedSetsByExerciseLineId: _plannedSetsByLineId(),
    );
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
      }
      return;
    }

    setState(() => _finishing = true);
    try {
      await _repository.completePlanSessionWithLogs(planSessionId, request);
    } catch (e) {
      if (mounted) {
        setState(() => _finishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
      return;
    }

    await _completedLocal.markPlanSessionCompletedThisWeek(
      planId: widget.detail.id,
      planSessionId: planSessionId,
    );

    if (!mounted) return;

    final durationMinutes =
        DateTime.now().difference(_startTime).inMinutes.clamp(0, 999);
    var completedSets = 0;
    var skippedSets = 0;
    var missedSets = 0;
    var totalSets = 0;
    var exercisesFullyCompleted = 0;
    final withSets = exercises.where((e) => e.sets > 0).length;
    for (var i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      if (ex.sets <= 0) continue;
      totalSets += ex.sets;
      var allCompleted = true;
      for (final e in _setLogs[i]) {
        switch (e.outcome) {
          case SetLogOutcome.completed:
            completedSets++;
          case SetLogOutcome.skipped:
            skippedSets++;
            allCompleted = false;
          case SetLogOutcome.missed:
            missedSets++;
            allCompleted = false;
        }
      }
      if (allCompleted) exercisesFullyCompleted++;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => TraineeWorkoutCompleteScreen(
          durationMinutes: durationMinutes,
          setsDone: completedSets,
          totalSets: totalSets,
          exercisesDone: exercisesFullyCompleted,
          totalExercises: withSets,
          skippedSets: skippedSets,
          missedSets: missedSets,
        ),
      ),
    );
  }

  void _showSkipSetSheet(BuildContext context, TraineeExerciseItem current) {
    final setNumber = _loggedFor(_currentExerciseIndex) + 1;
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var selectedReason = '';
        var skipKind = SetLogOutcome.skipped;

        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Log set outcome',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${current.name} — Set $setNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<SetLogOutcome>(
                    segments: const [
                      ButtonSegment<SetLogOutcome>(
                        value: SetLogOutcome.skipped,
                        label: Text('Skipped'),
                      ),
                      ButtonSegment<SetLogOutcome>(
                        value: SetLogOutcome.missed,
                        label: Text('Missed'),
                      ),
                    ],
                    selected: {skipKind},
                    onSelectionChanged: (next) {
                      setSheet(() => skipKind = next.first);
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skipKind == SetLogOutcome.skipped
                        ? 'Skipped: you chose not to do this set (e.g. equipment, time).'
                        : 'Missed: you attempted but did not complete (e.g. failed rep).',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Injury / Pain',
                      'Too tired',
                      'Too heavy',
                      'Not enough time',
                      'Other',
                    ].map((reason) {
                      final selected = selectedReason == reason;
                      return ChoiceChip(
                        label: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (_) {
                          setSheet(() => selectedReason = reason);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Reason (required for skipped / missed)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        var finalReason = selectedReason;
                        if (controller.text.isNotEmpty) {
                          finalReason +=
                              (finalReason.isNotEmpty ? ' - ' : '') +
                                  controller.text;
                        }
                        if (finalReason.trim().isEmpty) {
                          finalReason = 'No reason provided';
                        }
                        await _markSetCompleted(
                          current,
                          outcome: skipKind,
                          reason: finalReason.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }
}

class _RunnerSetLog {
  final SetLogOutcome outcome;
  final String? reason;

  _RunnerSetLog.completed()
      : outcome = SetLogOutcome.completed,
        reason = null;

  _RunnerSetLog.skipped(this.reason) : outcome = SetLogOutcome.skipped;

  _RunnerSetLog.missed(this.reason) : outcome = SetLogOutcome.missed;

  bool get isCompleted => outcome == SetLogOutcome.completed;
}

