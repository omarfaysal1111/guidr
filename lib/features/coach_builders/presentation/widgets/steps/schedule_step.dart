import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/workout_builder_bloc.dart';
import '../../bloc/workout_builder_event.dart';
import '../../bloc/workout_builder_state.dart';

class ScheduleStep extends StatelessWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBuilderBloc, WorkoutBuilderState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionLabel(label: 'ASSIGNMENT DATE'),
            const SizedBox(height: 8),
            _DatePicker(selectedDate: state.selectedDate),
            const SizedBox(height: 24),
            const _SectionLabel(label: 'RECURRENCE'),
            const SizedBox(height: 8),
            _RecurrenceGrid(selected: state.recurrence),
            const SizedBox(height: 24),
            const _SectionLabel(label: 'NOTIFICATIONS'),
            const SizedBox(height: 8),
            _NotificationToggles(
              remindTrainee: state.remindTrainee,
              alertIfMissed: state.alertIfMissed,
            ),
            const SizedBox(height: 24),
            _AssignmentSummary(state: state),
          ],
        );
      },
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  const _DatePicker({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final display = selectedDate != null
        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        : 'Select date (or assign immediately)';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && context.mounted) {
          context
              .read<WorkoutBuilderBloc>()
              .add(UpdateSchedule(selectedDate: picked));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(display,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  )),
            ),
            if (selectedDate != null)
              InkWell(
                onTap: () => context
                    .read<WorkoutBuilderBloc>()
                    .add(UpdateSchedule(selectedDate: DateTime.now())),
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecurrenceGrid extends StatelessWidget {
  final String selected;
  const _RecurrenceGrid({required this.selected});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('One-time', Icons.looks_one),
      ('Weekly', Icons.calendar_view_week),
      ('Monthly', Icons.calendar_month),
    ];
    return Row(
      children: options.map((opt) {
        final isActive = selected == opt.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context
                  .read<WorkoutBuilderBloc>()
                  .add(UpdateSchedule(recurrence: opt.$1)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                      width: isActive ? 2 : 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(opt.$2,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(opt.$1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NotificationToggles extends StatelessWidget {
  final bool remindTrainee;
  final bool alertIfMissed;
  const _NotificationToggles({
    required this.remindTrainee,
    required this.alertIfMissed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Remind trainee before workout',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Send notification 30 min before',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            value: remindTrainee,
            onChanged: (v) => context
                .read<WorkoutBuilderBloc>()
                .add(UpdateSchedule(remindTrainee: v)),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Alert if missed',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Notify you when trainee misses a session',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            value: alertIfMissed,
            onChanged: (v) => context
                .read<WorkoutBuilderBloc>()
                .add(UpdateSchedule(alertIfMissed: v)),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _AssignmentSummary extends StatelessWidget {
  final WorkoutBuilderState state;
  const _AssignmentSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalExercises =
        state.warmUp.length + state.mainExercises.length + state.coolDown.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${state.selectedTraineeIds.length} trainees · $totalExercises exercises · ${state.recurrence}',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ));
  }
}
