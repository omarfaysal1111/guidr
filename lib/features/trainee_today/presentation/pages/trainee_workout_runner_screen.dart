import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_exercise_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
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
  int _currentExerciseIndex = 0;
  final Map<int, int> _completedSetsPerExercise = {};
  String _weightText = '60 kg';
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _repository = di.sl<TraineeAppRepository>();
    if (widget.detail.exercises.isNotEmpty) {
      _weightText = widget.detail.exercises.first.load ?? '60 kg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.detail.exercises;
    final totalSets =
        exercises.fold<int>(0, (sum, e) => sum + (e.sets > 0 ? e.sets : 0));
    final completedSets = _completedSetsPerExercise.values.fold<int>(
        0, (sum, v) => sum + (v > 0 ? v : 0));

    final current = exercises[_currentExerciseIndex];
    final currentCompleted = _completedSetsPerExercise[_currentExerciseIndex] ??
        0; // 0..current.sets

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header timer + sets summary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
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
                    'Skip Set',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _markSetCompleted(current);
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
                await _advanceToNextOrFinish();
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
          final completed = _completedSetsPerExercise[index] ?? 0;
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
                          '$completed/${e.sets} sets',
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

  Future<void> _markSetCompleted(TraineeExerciseItem current) async {
    final currentCompleted =
        _completedSetsPerExercise[_currentExerciseIndex] ?? 0;
    if (currentCompleted >= current.sets) {
      await _advanceToNextOrFinish();
      return;
    }

    final newCompleted = currentCompleted + 1;
    setState(() {
      _completedSetsPerExercise[_currentExerciseIndex] = newCompleted;
    });

    if (newCompleted >= current.sets) {
      await _advanceToNextOrFinish();
    }
  }

  Future<void> _advanceToNextOrFinish() async {
    final exercises = widget.detail.exercises;
    final totalSets =
        exercises.fold<int>(0, (sum, e) => sum + (e.sets > 0 ? e.sets : 0));
    final completedSets = _completedSetsPerExercise.values
        .fold<int>(0, (sum, v) => sum + (v > 0 ? v : 0));

    final exercisesDone = exercises.asMap().entries
        .where((entry) =>
            (_completedSetsPerExercise[entry.key] ?? 0) >= entry.value.sets)
        .length;

    if (completedSets >= totalSets) {
      await _finishWorkout(
        completedSets: completedSets,
        totalSets: totalSets,
        exercisesDone: exercisesDone,
      );
    } else if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _weightText = exercises[_currentExerciseIndex].load ?? _weightText;
      });
    }
  }

  Future<void> _finishWorkout({
    required int completedSets,
    required int totalSets,
    required int exercisesDone,
  }) async {
    final exercises = widget.detail.exercises;
    final durationMinutes =
        DateTime.now().difference(_startTime).inMinutes.clamp(0, 999);
    final skipped = totalSets - completedSets;

    try {
      await _repository.completeWorkout(widget.detail.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => TraineeWorkoutCompleteScreen(
          durationMinutes: durationMinutes,
          setsDone: completedSets,
          totalSets: totalSets,
          exercisesDone: exercisesDone,
          totalExercises: exercises.length,
          skippedSets: skipped,
        ),
      ),
    );
  }

  void _showSkipSetSheet(BuildContext context, TraineeExerciseItem current) {
    final setNumber = (_completedSetsPerExercise[_currentExerciseIndex] ?? 0) + 1;
    final controller = TextEditingController();
    String selectedReason = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                  const Text(
                    'Why are you skipping this set?',
                    style: TextStyle(
                      fontSize: 16,
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
              Text(
                'Skipping: ${current.name} — Set $setNumber',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
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
                  return StatefulBuilder(
                    builder: (context, setChipState) {
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
                          setChipState(() {
                            selectedReason = reason;
                          });
                        },
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Type your reason here...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _markSetCompleted(current);
                    Navigator.pop(ctx);
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
                    'Skip Set',
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
  }
}

