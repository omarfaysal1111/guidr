import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/data/local/plan_builder_local_storage.dart';
import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
import 'package:guidr/l10n/app_localizations.dart';
import '../../bloc/workout_builder_bloc.dart';
import '../../bloc/workout_builder_event.dart';
import '../../bloc/workout_builder_state.dart';

class ReviewConfirmStep extends StatelessWidget {
  const ReviewConfirmStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<WorkoutBuilderBloc, WorkoutBuilderState>(
      builder: (context, state) {
        final totalExercises = state.totalExerciseCount;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeaderBanner(state: state, totalExercises: totalExercises),
            const SizedBox(height: 20),
            _ReviewCard(
              icon: Icons.people,
              iconColor: const Color(0xFF3B82F6),
              title: l.trainees,
              onEdit: () =>
                  context.read<WorkoutBuilderBloc>().add(const SetStep(1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.traineesSelected(state.selectedTraineeIds.length),
                      style: const TextStyle(fontSize: 14)),
                  if (state.allTrainees.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: state.allTrainees
                          .where((t) => state.selectedTraineeIds.contains(t.id))
                          .map((t) => Chip(
                                label: Text(t.name,
                                    style: const TextStyle(fontSize: 12)),
                                avatar: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text(t.avatar,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white))),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              icon: Icons.fitness_center,
              iconColor: AppColors.primary,
              title: l.planAndSessions,
              onEdit: () =>
                  context.read<WorkoutBuilderBloc>().add(const SetStep(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.planTitle.isEmpty ? l.untitledPlan : state.planTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...state.sessions.asMap().entries.expand((e) {
                    final i = e.key;
                    final s = e.value;
                    final label = s.title.trim().isEmpty
                        ? l.sessionNumber(i + 1)
                        : s.title.trim();
                    return [
                      _ExerciseGroupHeader(
                        label: label,
                        count: s.exercises.length,
                      ),
                      ...s.exercises.map(
                        (ex) => _ExerciseReviewRow(exercise: ex),
                      ),
                      const SizedBox(height: 8),
                    ];
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              icon: Icons.calendar_today,
              iconColor: AppColors.warning,
              title: l.schedule,
              onEdit: () =>
                  context.read<WorkoutBuilderBloc>().add(const SetStep(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                      label: l.date,
                      value: state.selectedDate != null
                          ? '${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}'
                          : l.immediatelyLabel),
                  _InfoRow(label: l.recurrence, value: state.recurrence),
                  _InfoRow(
                      label: l.remindTrainee,
                      value: state.remindTrainee ? 'Yes' : 'No'),
                  _InfoRow(
                      label: l.alertIfMissed,
                      value: state.alertIfMissed ? 'Yes' : 'No'),
                ],
              ),
            ),
            if (state.instructions.isNotEmpty || state.caution.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ReviewCard(
                icon: Icons.notes,
                iconColor: AppColors.textSecondary,
                title: l.notes,
                onEdit: () =>
                    context.read<WorkoutBuilderBloc>().add(const SetStep(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.instructions.isNotEmpty)
                      Text('${l.descriptionInstructions}: ${state.instructions}',
                          style: const TextStyle(fontSize: 13)),
                    if (state.caution.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${l.cautionNotesLabel}: ${state.caution}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.warning)),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.saving
                  ? null
                  : () => context
                      .read<WorkoutBuilderBloc>()
                      .add(AssignWorkout()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: state.saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(l.confirmAndAssignWorkout,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.saving
                        ? null
                        : () => context
                            .read<WorkoutBuilderBloc>()
                            .add(SaveWorkoutDraft()),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(l.saveDraft),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.saving
                        ? null
                        : () => context
                            .read<WorkoutBuilderBloc>()
                            .add(SaveWorkoutTemplate()),
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: Text(l.saveTemplate),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.savedOnDevice,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: state.saving
                      ? null
                      : () => context
                          .read<WorkoutBuilderBloc>()
                          .add(const RestoreWorkoutDraftFromLocal()),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: Text(l.loadDraft),
                ),
                TextButton.icon(
                  onPressed: state.saving
                      ? null
                      : () => _showWorkoutTemplatePicker(context),
                  icon: const Icon(Icons.bookmarks_outlined, size: 18),
                  label: Text(l.loadTemplateBtn),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

void _showWorkoutTemplatePicker(BuildContext context) {
  final store = di.sl<PlanBuilderLocalStorage>();
  final list = store.listWorkoutTemplates();
  if (list.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No saved templates on this device yet.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Workout templates (device storage)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...list.map(
            (m) {
              final id = m['id'] as String? ?? '';
              final name = m['name'] as String? ?? 'Untitled';
              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<WorkoutBuilderBloc>().add(
                        RestoreWorkoutTemplateFromLocal(id),
                      );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _HeaderBanner extends StatelessWidget {
  final WorkoutBuilderState state;
  final int totalExercises;
  const _HeaderBanner({required this.state, required this.totalExercises});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.planTitle.isEmpty ? 'New plan' : state.planTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Final check before sending to trainees',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBadge(
                  label: 'Trainees',
                  value: '${state.selectedTraineeIds.length}'),
              const SizedBox(width: 12),
              _StatBadge(label: 'Exercises', value: '$totalExercises'),
              const SizedBox(width: 12),
              _StatBadge(label: 'Difficulty', value: state.difficulty),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label: $value',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final VoidCallback onEdit;

  const _ReviewCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              TextButton(
                onPressed: onEdit,
                child: const Text('Edit',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ExerciseGroupHeader extends StatelessWidget {
  final String label;
  final int count;
  const _ExerciseGroupHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label ($count)',
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary)),
    );
  }
}

class _ExerciseReviewRow extends StatelessWidget {
  final BuilderExercise exercise;
  const _ExerciseReviewRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(exercise.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(
            '${exercise.sets}×${exercise.reps}',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          if (exercise.load != null && exercise.load!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(exercise.load!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ],
          if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
            const SizedBox(width: 6),
            const Icon(Icons.play_circle_outline,
                size: 14, color: AppColors.primary),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
