import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/domain/entities/builder_exercise.dart';
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
            _NameField(name: state.workoutName),
            const SizedBox(height: 20),
            _DifficultySelector(current: state.difficulty),
            const SizedBox(height: 24),
            _ExerciseSection(
              section: BuilderSection.warmUp,
              label: 'WARM-UP',
              icon: Icons.whatshot,
              color: AppColors.warning,
              exercises: state.warmUp,
              expanded: state.warmUpExpanded,
            ),
            const SizedBox(height: 12),
            _ExerciseSection(
              section: BuilderSection.main,
              label: 'MAIN EXERCISES',
              icon: Icons.fitness_center,
              color: AppColors.primary,
              exercises: state.mainExercises,
              expanded: state.mainExpanded,
            ),
            const SizedBox(height: 12),
            _ExerciseSection(
              section: BuilderSection.coolDown,
              label: 'COOL-DOWN',
              icon: Icons.ac_unit,
              color: const Color(0xFF3B82F6),
              exercises: state.coolDown,
              expanded: state.coolDownExpanded,
            ),
            const SizedBox(height: 24),
            _InstructionsField(value: state.instructions),
            const SizedBox(height: 16),
            _CautionField(value: state.caution),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  final String name;
  const _NameField({required this.name});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: name,
      onChanged: (val) => context
          .read<WorkoutBuilderBloc>()
          .add(UpdateWorkoutMetadata(name: val)),
      decoration: InputDecoration(
        hintText: 'Workout Name *',
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

class _DifficultySelector extends StatelessWidget {
  final String current;
  const _DifficultySelector({required this.current});

  @override
  Widget build(BuildContext context) {
    final levels = ['Easy', 'Medium', 'Hard'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIFFICULTY LEVEL',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: levels.map((level) {
            final selected = current == level;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(level),
                selected: selected,
                onSelected: (s) {
                  if (s) {
                    context
                        .read<WorkoutBuilderBloc>()
                        .add(UpdateWorkoutMetadata(difficulty: level));
                  }
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ExerciseSection extends StatelessWidget {
  final BuilderSection section;
  final String label;
  final IconData icon;
  final Color color;
  final List<BuilderExercise> exercises;
  final bool expanded;

  const _ExerciseSection({
    required this.section,
    required this.label,
    required this.icon,
    required this.color,
    required this.exercises,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context
                .read<WorkoutBuilderBloc>()
                .add(ToggleSectionExpanded(section)),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('$label (${exercises.length})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            ...exercises.asMap().entries.map((e) =>
                _ExerciseRow(
                    section: section,
                    index: e.key,
                    exercise: e.value)),
            _AddButtons(section: section),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final BuilderSection section;
  final int index;
  final BuilderExercise exercise;

  const _ExerciseRow({
    required this.section,
    required this.index,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(exercise.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
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
                  child: const Text('Edit',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context
                    .read<WorkoutBuilderBloc>()
                    .add(RemoveExercise(section, index)),
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _DetailChip(
                  icon: Icons.repeat, label: '${exercise.sets} sets'),
              _DetailChip(
                  icon: Icons.fitness_center,
                  label: '${exercise.reps} reps'),
              if (exercise.load != null && exercise.load!.isNotEmpty)
                _DetailChip(
                    icon: Icons.monitor_weight_outlined,
                    label: exercise.load!),
              if (exercise.rest != null && exercise.rest!.isNotEmpty)
                _DetailChip(
                    icon: Icons.timer_outlined, label: exercise.rest!),
            ],
          ),
          if (exercise.videoUrl != null &&
              exercise.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.play_circle_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Video attached',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final bloc = context.read<WorkoutBuilderBloc>();
    final setsCtrl =
        TextEditingController(text: exercise.sets.toString());
    final repsCtrl = TextEditingController(text: exercise.reps);
    final loadCtrl =
        TextEditingController(text: exercise.load ?? '');
    final restCtrl =
        TextEditingController(text: exercise.rest ?? '');
    final videoCtrl =
        TextEditingController(text: exercise.videoUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            Text(exercise.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Sets', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Reps', border: OutlineInputBorder()),
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
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: restCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Rest (e.g. 90s)',
                        border: OutlineInputBorder()),
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
                  prefixIcon: Icon(Icons.play_circle_outline)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  bloc.add(UpdateExerciseDetails(
                    section: section,
                    index: index,
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Details',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
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
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AddButtons extends StatelessWidget {
  final BuilderSection section;
  const _AddButtons({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAddCustomDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showLibrarySheet(context),
              icon: const Icon(Icons.local_library_outlined, size: 18),
              label: const Text('Library'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final bloc = context.read<WorkoutBuilderBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Exercise'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'Exercise name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                bloc.add(AddExercise.custom(section, name));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLibrarySheet(BuildContext context) {
    final bloc = context.read<WorkoutBuilderBloc>();
    bloc.add(LoadLibraryExercises());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                section: section,
                scrollController: scrollCtrl,
              ),
            );
          },
        );
      },
    );
  }
}

class _LibraryContent extends StatefulWidget {
  final BuilderSection section;
  final ScrollController scrollController;
  const _LibraryContent(
      {required this.section, required this.scrollController});

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
                  const Text('Exercise Library',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child:
                      Center(child: CircularProgressIndicator()))
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
                        child: const Icon(Icons.fitness_center,
                            size: 20, color: AppColors.primary),
                      ),
                      title: Text(ex.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: ex.videoUrl != null
                          ? const Text('Has video',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary))
                          : null,
                      trailing: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      onTap: () {
                        context.read<WorkoutBuilderBloc>().add(
                            AddExercise.fromLibrary(
                                widget.section, ex));
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
        const Text('INSTRUCTIONS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: (v) => context
              .read<WorkoutBuilderBloc>()
              .add(UpdateWorkoutMetadata(instructions: v)),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add workout instructions...',
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
        const Text('CAUTION / NOTES',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: (v) => context
              .read<WorkoutBuilderBloc>()
              .add(UpdateWorkoutMetadata(caution: v)),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add caution or coach notes...',
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
