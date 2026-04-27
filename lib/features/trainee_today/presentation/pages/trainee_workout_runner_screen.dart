// ignore_for_file: deprecated_member_use

import 'dart:async';
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

  // Live timer
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Video tab state
  int _selectedVideoTab = 0;

  // Reps counter state
  int _repsCount = 0;

  int _loggedFor(int exerciseIndex) => _setLogs[exerciseIndex].length;

  int _completedFor(int exerciseIndex) =>
      _setLogs[exerciseIndex].where((e) => e.isCompleted).length;

  int _skippedFor(int exerciseIndex) => _setLogs[exerciseIndex]
      .where((e) => e.outcome == SetLogOutcome.skipped)
      .length;

  int _missedFor(int exerciseIndex) =>
      _setLogs[exerciseIndex].where((e) => e.outcome == SetLogOutcome.missed).length;

  String get _formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _finishedExercisesCount() {
    final exercises = widget.detail.exercises;
    var count = 0;
    for (var i = 0; i < exercises.length; i++) {
      if (_loggedFor(i) >= exercises[i].sets) count++;
    }
    return count;
  }

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
      final first = widget.detail.exercises.first;
      _weightText = first.load ?? '60 kg';
      _repsCount = int.tryParse(first.reps.toString()) ?? 0;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    final allDone = exercises.every((e) => _loggedFor(exercises.indexOf(e)) >= e.sets);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header: Back | Timer | Pause + sets
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: AppColors.textPrimary),
                        onPressed:
                            _finishing ? null : () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'WORKOUT TIME',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedTime,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.pause_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedSets/$totalSets sets',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: totalSets == 0 ? 0 : completedSets / totalSets,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
                        const SizedBox(height: 16),
                        // Finish / End Early button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline,
                                size: 20),
                            label: Text(
                              allDone
                                  ? 'Finish Workout'
                                  : 'End Workout Early (${_finishedExercisesCount()}/${exercises.length} done)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: _finishing
                                ? null
                                : () async {
                                    if (!allDone) {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: const Text('End workout early?'),
                                          content: const Text(
                                            'You have not completed all exercises. Your progress so far will still be saved.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.success,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('End Anyway'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                    }
                                    await _finishWorkout();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Loading overlay
            if (_finishing)
              Positioned.fill(
                child: AbsorbPointer(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Saving session…',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
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
    final videoTabs = ['Front View', 'Side View', 'Close-up', 'Slow-mo'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / image placeholder
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
                    size: 46,
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
            const SizedBox(height: 8),
            // Video angle tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: videoTabs.asMap().entries.map((e) {
                  final isSelected = _selectedVideoTab == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedVideoTab = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Muscle group chip
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            const SizedBox(height: 10),
            // Exercise counter label
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
            // Exercise name
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
            const SizedBox(height: 10),
            // Exercise description
            const Text(
              'Perform this exercise with proper form and full range of motion.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Set buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(current.sets, (index) {
                final setNumber = index + 1;
                final isDone = setNumber <= currentCompleted;
                final isActive = setNumber == currentCompleted + 1;
                Color bg;
                Color fg;
                Color borderColor;
                if (isDone) {
                  bg = AppColors.primary;
                  fg = Colors.white;
                  borderColor = AppColors.primary;
                } else if (isActive) {
                  bg = Colors.white;
                  fg = AppColors.primary;
                  borderColor = AppColors.primary;
                } else {
                  bg = AppColors.surface;
                  fg = AppColors.textSecondary;
                  borderColor = AppColors.border;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDone) ...[
                        const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        'Set $setNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            // Coach focus tip (from coachNote if available)
            // if ((current. ?? '').isNotEmpty)
            //   Container(
            //     margin: const EdgeInsets.only(bottom: 8),
            //     padding: const EdgeInsets.symmetric(
            //         horizontal: 12, vertical: 10),
            //     decoration: BoxDecoration(
            //       color: AppColors.successLight,
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: AppColors.success.withOpacity(0.3)),
            //     ),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         const Icon(Icons.tips_and_updates_outlined,
            //             size: 15, color: AppColors.success),
            //         const SizedBox(width: 6),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               const Text(
            //                 "Coach's Focus",
            //                 style: TextStyle(
            //                   fontSize: 10,
            //                   fontWeight: FontWeight.w700,
            //                   color: AppColors.success,
            //                   letterSpacing: 0.3,
            //                 ),
            //               ),
            //               const SizedBox(height: 2),
            //               Text(
            //                 current.coachNote!,
            //                 style: const TextStyle(
            //                   fontSize: 12,
            //                   color: AppColors.success,
            //                   fontWeight: FontWeight.w500,
            //                   height: 1.3,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // Static form tip
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      size: 15, color: AppColors.warning),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Keep chest up, maintain proper form',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Weight row with +/- buttons
            _buildWeightRow(),
            const SizedBox(height: 10),
            // Reps row with +/- buttons
            _buildRepsRow(),
            const SizedBox(height: 16),
            // Skip or miss | Complete Set buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showSkipSetSheet(context, current);
                  },
                  icon: const Icon(Icons.close, size: 15),
                  label: const Text(
                    'Skip or miss',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning, width: 1.5),
                    backgroundColor: AppColors.warningLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), Color(0xFF2BC48A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _markSetCompleted(
                          current,
                          outcome: SetLogOutcome.completed,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'Complete Set ${currentCompleted + 1 > current.sets ? current.sets : currentCompleted + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightRow() {
    return Row(
      children: [
        const SizedBox(
          width: 52,
          child: Text(
            'Weight:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Minus button
                _squareIconBtn(
                  icon: Icons.remove,
                  onTap: () {
                    setState(() {
                      final numMatch =
                          RegExp(r'(\d+(?:\.\d+)?)').firstMatch(_weightText);
                      if (numMatch != null) {
                        final val =
                            double.tryParse(numMatch.group(1) ?? '') ?? 0;
                        final newVal = (val - 2.5).clamp(0, 999);
                        _weightText = _weightText.replaceFirst(
                          numMatch.group(0)!,
                          newVal % 1 == 0
                              ? newVal.toInt().toString()
                              : newVal.toStringAsFixed(1),
                        );
                      }
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _weightText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Plus button
                _squareIconBtn(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      final numMatch =
                          RegExp(r'(\d+(?:\.\d+)?)').firstMatch(_weightText);
                      if (numMatch != null) {
                        final val =
                            double.tryParse(numMatch.group(1) ?? '') ?? 0;
                        final newVal = val + 2.5;
                        _weightText = _weightText.replaceFirst(
                          numMatch.group(0)!,
                          newVal % 1 == 0
                              ? newVal.toInt().toString()
                              : newVal.toStringAsFixed(1),
                        );
                      }
                    });
                  },
                ),
                const SizedBox(width: 2),
                // Edit button
                GestureDetector(
                  onTap: () => _showWeightEditDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepsRow() {
    return Row(
      children: [
        const SizedBox(
          width: 52,
          child: Text(
            'Reps:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _squareIconBtn(
                  icon: Icons.remove,
                  onTap: () {
                    setState(() {
                      if (_repsCount > 0) _repsCount--;
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_repsCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                _squareIconBtn(
                  icon: Icons.add,
                  onTap: () {
                    setState(() => _repsCount++);
                  },
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => _showRepsEditDialog(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _squareIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  void _showWeightEditDialog() {
    final controller = TextEditingController(text: _weightText);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Weight'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. 80 kg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() => _weightText = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showRepsEditDialog() {
    final controller =
        TextEditingController(text: _repsCount.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Reps'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 12',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0) {
                setState(() => _repsCount = parsed);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
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
                _repsCount = int.tryParse(e.reps.toString()) ?? 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent ? AppColors.primary : AppColors.border,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? Colors.white
                            : AppColors.textSecondary,
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
                  const SizedBox(width: 8),
                  // Mini set progress dots
                  Row(
                    children: List.generate(e.sets, (si) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: si < _loggedFor(index)
                            ? AppColors.success
                            : AppColors.surface,
                        border: Border.all(
                          color: si < _loggedFor(index)
                              ? AppColors.success
                              : AppColors.border,
                          width: 0.8,
                        ),
                      ),
                    )),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How are you feeling? Any adjustments?',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
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
          final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(_weightText);
          final parsedKg = numMatch != null
              ? double.tryParse(numMatch.group(1) ?? '')
              : null;
          _setLogs[i].add(_RunnerSetLog.completed(weightKg: parsedKg, reps: _repsCount));
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
        _setLogs[i].add(_RunnerSetLog.skipped('Entire exercise skipped'));
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
        _repsCount = int.tryParse(exercises[_currentExerciseIndex].reps.toString()) ?? 0;
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
          row.add(ExerciseSetLogRequest(
            outcome: SetLogOutcome.completed,
            weightKg: entry.weightKg,
            reps: entry.reps,
          ));
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Log set outcome',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${current.name} — Set $setNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<SetLogOutcome>(
                    segments: const [
                      ButtonSegment<SetLogOutcome>(
                        value: SetLogOutcome.skipped,
                        label: Text('Skipped'),
                        icon: Icon(Icons.skip_next_rounded, size: 16),
                      ),
                      ButtonSegment<SetLogOutcome>(
                        value: SetLogOutcome.missed,
                        label: Text('Missed'),
                        icon: Icon(Icons.close_rounded, size: 16),
                      ),
                    ],
                    selected: {skipKind},
                    onSelectionChanged: (next) {
                      setSheet(() => skipKind = next.first);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return AppColors.surface;
                      }),
                      foregroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return AppColors.textSecondary;
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 14),
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
                      return GestureDetector(
                        onTap: () {
                          setSheet(() => selectedReason = reason);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
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
                        hintText: 'Reason (required for skipped / missed)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
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
  final double? weightKg;
  final int? reps;

  _RunnerSetLog.completed({this.weightKg, this.reps})
      : outcome = SetLogOutcome.completed,
        reason = null;

  _RunnerSetLog.skipped(this.reason) : outcome = SetLogOutcome.skipped, weightKg = null, reps = null;

  _RunnerSetLog.missed(this.reason) : outcome = SetLogOutcome.missed, weightKg = null, reps = null;

  bool get isCompleted => outcome == SetLogOutcome.completed;
}
