import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';
import '../../bloc/nutrition_builder_state.dart';

class NutritionScheduleStep extends StatelessWidget {
  const NutritionScheduleStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _Label(text: 'DATE'),
            const SizedBox(height: 8),
            _DatePicker(selectedDate: state.selectedDate),
            const SizedBox(height: 20),
            const _Label(text: 'TIME'),
            const SizedBox(height: 8),
            _TimePicker(selectedTime: state.selectedTime),
            const SizedBox(height: 20),
            const _Label(text: 'RECURRENCE'),
            const SizedBox(height: 8),
            _RecurrenceGrid(selected: state.recurrence),
            const SizedBox(height: 24),
            const _Label(text: 'NOTIFICATIONS'),
            const SizedBox(height: 8),
            _NotificationToggles(
              remindTrainee: state.remindTrainee,
              alertIfMissed: state.alertIfMissed,
            ),
            const SizedBox(height: 20),
            _ScheduleSummary(state: state),
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
    final d = selectedDate ?? DateTime.now();
    final display =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
              .read<NutritionBuilderBloc>()
              .add(NutritionUpdateSchedule(selectedDate: picked));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(display,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String selectedTime;
  const _TimePicker({required this.selectedTime});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final parts = selectedTime.split(':');
        final initial = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
        final picked =
            await showTimePicker(context: context, initialTime: initial);
        if (picked != null && context.mounted) {
          context.read<NutritionBuilderBloc>().add(NutritionUpdateSchedule(
              selectedTime:
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(selectedTime,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
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
    final options = ['One-time', 'Weekly', 'Bi-weekly', 'Monthly'];
    return Row(
      children: options.map((r) {
        final isActive = selected == r;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context
                  .read<NutritionBuilderBloc>()
                  .add(NutritionUpdateSchedule(recurrence: r)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border),
                ),
                child: Center(
                  child: Text(r,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive ? Colors.white : AppColors.textSecondary,
                      )),
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
            title: const Text('Remind trainee before session',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            value: remindTrainee,
            onChanged: (v) => context
                .read<NutritionBuilderBloc>()
                .add(NutritionUpdateSchedule(remindTrainee: v)),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Alert me if plan missed',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            value: alertIfMissed,
            onChanged: (v) => context
                .read<NutritionBuilderBloc>()
                .add(NutritionUpdateSchedule(alertIfMissed: v)),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ScheduleSummary extends StatelessWidget {
  final NutritionBuilderState state;
  const _ScheduleSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final d = state.selectedDate ?? DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(months[d.month - 1],
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('${d.day}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    state.planName.isEmpty
                        ? 'Nutrition Plan'
                        : state.planName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(
                    '${state.totalMeals} meals · ~${state.estimatedKcal} kcal',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text('${state.recurrence} session',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ));
  }
}
