import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
import 'package:guidr/features/coach_builders/domain/entities/workout_plan_session_draft.dart';
import '../../bloc/workout_builder_bloc.dart';
import '../../bloc/workout_builder_event.dart';
import '../../bloc/workout_builder_state.dart';

class ExerciseBuilderStep extends StatelessWidget {
  const ExerciseBuilderStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBuilderBloc, WorkoutBuilderState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'PLAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _PlanTitleField(title: state.planTitle),
            const SizedBox(height: 20),
            _InstructionsField(value: state.instructions),
            const SizedBox(height: 16),
            _CautionField(value: state.caution),
            const SizedBox(height: 28),
            Row(
              children: [
                const Text(
                  'SESSIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context
                      .read<WorkoutBuilderBloc>()
                      .add(const AddPlanSession()),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add session'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Name each day (e.g. Leg Day) and add exercises from the library.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            ...state.sessions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SessionCard(
                      sessionIndex: e.key,
                      session: e.value,
                      canRemove: state.sessions.length > 1,
                    ),
                  ),
                ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _PlanTitleField extends StatelessWidget {
  final String title;
  const _PlanTitleField({required this.title});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: title,
      onChanged: (val) => context.read<WorkoutBuilderBloc>().add(
            UpdateWorkoutMetadata(planTitle: val),
          ),
      decoration: InputDecoration(
        labelText: 'Plan title *',
        hintText: 'e.g. 4-week strength block',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final int sessionIndex;
  final WorkoutPlanSessionDraft session;
  final bool canRemove;

  const _SessionCard({
    required this.sessionIndex,
    required this.session,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        session.title.trim().isEmpty ? 'Session ${sessionIndex + 1}' : session.title.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => context.read<WorkoutBuilderBloc>().add(
                  ToggleSessionExpanded(sessionIndex),
                ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event_note,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '${session.exercises.length} ex.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    session.expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (session.expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: TextFormField(
                initialValue: session.title,
                onChanged: (v) => context.read<WorkoutBuilderBloc>().add(
                      UpdateSessionTitle(sessionIndex, v),
                    ),
                decoration: InputDecoration(
                  labelText: 'Session title',
                  hintText: 'e.g. Push day, Leg day',
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (canRemove)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.read<WorkoutBuilderBloc>().add(
                        RemovePlanSession(sessionIndex),
                      ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove session'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
            ...session.exercises.asMap().entries.map(
                  (e) => _SessionExerciseRow(
                    sessionIndex: sessionIndex,
                    exerciseIndex: e.key,
                    exercise: e.value,
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLibrarySheet(context, sessionIndex),
                  icon: const Icon(Icons.local_library_outlined, size: 18),
                  label: const Text('Add from library'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLibrarySheet(BuildContext context, int sessionIndex) {
    final bloc = context.read<WorkoutBuilderBloc>();
    bloc.add(LoadLibraryExercises());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return BlocProvider.value(
              value: bloc,
              child: _LibraryContent(
                sessionIndex: sessionIndex,
                scrollController: scrollCtrl,
              ),
            );
          },
        );
      },
    );
  }
}

class _SessionExerciseRow extends StatelessWidget {
  final int sessionIndex;
  final int exerciseIndex;
  final BuilderExercise exercise;

  const _SessionExerciseRow({
    required this.sessionIndex,
    required this.exerciseIndex,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${exerciseIndex + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showEditSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.read<WorkoutBuilderBloc>().add(
                      RemoveSessionExercise(sessionIndex, exerciseIndex),
                    ),
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              _DetailChip(icon: Icons.repeat, label: '${exercise.sets} sets'),
              _DetailChip(
                icon: Icons.fitness_center,
                label: '${exercise.reps} reps',
              ),
              if (exercise.load != null && exercise.load!.isNotEmpty)
                _DetailChip(
                  icon: Icons.monitor_weight_outlined,
                  label: exercise.load!,
                ),
              if (exercise.rest != null && exercise.rest!.isNotEmpty)
                _DetailChip(
                  icon: Icons.timer_outlined,
                  label: exercise.rest!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final bloc = context.read<WorkoutBuilderBloc>();
    final setsCtrl = TextEditingController(text: exercise.sets.toString());
    final repsCtrl = TextEditingController(text: exercise.reps);
    final loadCtrl = TextEditingController(text: exercise.load ?? '');
    final restCtrl = TextEditingController(text: exercise.rest ?? '');
    final videoCtrl = TextEditingController(text: exercise.videoUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: loadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Load (e.g. 60kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: restCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Rest (e.g. 90s)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: videoCtrl,
              decoration: const InputDecoration(
                labelText: 'Video URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.play_circle_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(UpdateSessionExerciseDetails(
                    sessionIndex: sessionIndex,
                    exerciseIndex: exerciseIndex,
                    sets: int.tryParse(setsCtrl.text) ?? exercise.sets,
                    reps: repsCtrl.text,
                    load: loadCtrl.text,
                    rest: restCtrl.text,
                    videoUrl: videoCtrl.text,
                  ));
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LibraryContent extends StatefulWidget {
  final int sessionIndex;
  final ScrollController scrollController;
  const _LibraryContent({
    required this.sessionIndex,
    required this.scrollController,
  });

  @override
  State<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<_LibraryContent> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBuilderBloc, WorkoutBuilderState>(
      builder: (context, state) {
        final filtered = _query.isEmpty
            ? state.libraryExercises
            : state.libraryExercises
                .where((e) =>
                    e.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Exercise library',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                onChanged: (q) => setState(() => _query = q),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (state.libraryLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final ex = filtered[i];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: ex.videoUrl != null
                          ? const Text(
                              'Has video',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        context.read<WorkoutBuilderBloc>().add(
                              AddExerciseFromLibrary(
                                widget.sessionIndex,
                                ex,
                              ),
                            );
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InstructionsField extends StatelessWidget {
  final String value;
  const _InstructionsField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESCRIPTION / INSTRUCTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: (v) => context.read<WorkoutBuilderBloc>().add(
                UpdateWorkoutMetadata(instructions: v),
              ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Optional plan description for trainees...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _CautionField extends StatelessWidget {
  final String value;
  const _CautionField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAUTION / NOTES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: (v) => context.read<WorkoutBuilderBloc>().add(
                UpdateWorkoutMetadata(caution: v),
              ),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Optional safety notes...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
