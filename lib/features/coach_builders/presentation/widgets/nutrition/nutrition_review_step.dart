// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/data/local/plan_builder_local_storage.dart';
import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';
import '../../bloc/nutrition_builder_state.dart';

class NutritionReviewStep extends StatelessWidget {
  const NutritionReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        final allMeals = [
          ...state.breakfast.map((m) => ('Breakfast', m)),
          ...state.lunch.map((m) => ('Lunch', m)),
          ...state.dinner.map((m) => ('Dinner', m)),
          ...state.snacks.map((m) => ('Snacks', m)),
        ];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeaderBanner(state: state),
            const SizedBox(height: 20),
            _ReviewCard(
              icon: Icons.people,
              iconColor: const Color(0xFF3B82F6),
              title: 'Assigned to',
              onEdit: () => context
                  .read<NutritionBuilderBloc>()
                  .add(const NutritionSetStep(1)),
              child: _buildTraineesContent(state),
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              icon: Icons.calendar_today,
              iconColor: AppColors.warning,
              title: 'Schedule',
              onEdit: () => context
                  .read<NutritionBuilderBloc>()
                  .add(const NutritionSetStep(4)),
              child: _buildScheduleContent(state),
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              icon: Icons.restaurant,
              iconColor: AppColors.primary,
              title: 'Meals',
              onEdit: () => context
                  .read<NutritionBuilderBloc>()
                  .add(const NutritionSetStep(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allMeals
                    .map((item) => _MealReviewRow(
                        entry: item.$2, category: item.$1))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Notifications',
              onEdit: () => context
                  .read<NutritionBuilderBloc>()
                  .add(const NutritionSetStep(4)),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trainee will be reminded${state.alertIfMissed ? ' · Alert if missed' : ''}',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<NutritionBuilderBloc>()
                  .add(NutritionSaveTemplate()),
              icon: Icon(Icons.folder_outlined, color: AppColors.primary),
              label: Text('Save as Template',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<NutritionBuilderBloc>()
                        .add(NutritionSaveDraft()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.saving
                        ? null
                        : () => context
                            .read<NutritionBuilderBloc>()
                            .add(NutritionAssignPlan()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Assign Nutrition Plan →',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Saved on this device (no cloud sync)',
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
                          .read<NutritionBuilderBloc>()
                          .add(const RestoreNutritionDraftFromLocal()),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Load draft'),
                ),
                TextButton.icon(
                  onPressed: state.saving
                      ? null
                      : () => _showNutritionTemplatePicker(context),
                  icon: const Icon(Icons.bookmarks_outlined, size: 18),
                  label: const Text('Load template…'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildTraineesContent(NutritionBuilderState state) {
    final selected = state.allTrainees
        .where((t) => state.selectedTraineeIds.contains(t.id))
        .toList();

    if (selected.isEmpty) {
      return const Text('No trainee selected',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary));
    }
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(selected.first.avatar,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(selected.map((t) => t.name).join(', '),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _buildScheduleContent(NutritionBuilderState state) {
    final d = state.selectedDate ?? DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final timeParts = state.selectedTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = timeParts.length > 1 ? timeParts[1] : '00';
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('${weekdays[d.weekday - 1]}, ${monthNames[d.month - 1]} ${d.day}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$displayHour:$minute $amPm · ${state.recurrence}',
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final NutritionBuilderState state;
  const _HeaderBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
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
                    state.planName.isEmpty
                        ? 'New Nutrition Plan'
                        : state.planName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              '${state.totalMeals} meals · ~${state.estimatedKcal} kcal',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBadge(
                  label: 'Trainees',
                  value: '${state.selectedTraineeIds.length}'),
              const SizedBox(width: 12),
              _StatBadge(
                  label: 'Meals', value: '${state.totalMeals}'),
              const SizedBox(width: 12),
              _StatBadge(
                  label: 'Kcal', value: '~${state.estimatedKcal}'),
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
                child: Text('Edit',
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

class _MealReviewRow extends StatelessWidget {
  final MealIngredientEntry entry;
  final String category;
  const _MealReviewRow({required this.entry, required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Row(
                  children: [
                    Text(category,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    if (entry.isFromLibrary) ...[
                      const Text(' · ',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted)),
                      Text(
                        '${entry.quantityG.toStringAsFixed(0)}g · '
                        '${entry.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showNutritionTemplatePicker(BuildContext context) {
  final store = di.sl<PlanBuilderLocalStorage>();
  final list = store.listNutritionTemplates();
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
              'Nutrition templates (device storage)',
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
                  context.read<NutritionBuilderBloc>().add(
                        RestoreNutritionTemplateFromLocal(id),
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
