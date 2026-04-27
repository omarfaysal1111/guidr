import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/data/local/plan_builder_local_storage.dart';
import 'package:guidr/l10n/app_localizations.dart';
import '../../bloc/workout_builder_bloc.dart';
import '../../bloc/workout_builder_event.dart';

class TemplateStartingStep extends StatelessWidget {
  const TemplateStartingStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final savedTemplates =
        di.sl<PlanBuilderLocalStorage>().listWorkoutTemplates();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StartFromScratchCard(
          onTap: () =>
              context.read<WorkoutBuilderBloc>().add(const SetStep(3)),
        ),
        const SizedBox(height: 16),
        _DraftsCard(
          onTap: () => context
              .read<WorkoutBuilderBloc>()
              .add(const RestoreWorkoutDraftFromLocal()),
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: l.savedTemplates),
        const SizedBox(height: 12),
        if (savedTemplates.isEmpty)
          const _EmptyTemplates()
        else
          ...savedTemplates.map(
            (m) => _SavedTemplateCard(
              id: m['id'] as String? ?? '',
              name: m['name'] as String? ?? 'Untitled',
              savedAt: m['savedAt'] as String?,
            ),
          ),
      ],
    );
  }
}

class _SavedTemplateCard extends StatelessWidget {
  final String id;
  final String name;
  final String? savedAt;

  const _SavedTemplateCard({
    required this.id,
    required this.name,
    this.savedAt,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = '';
    if (savedAt != null) {
      final dt = DateTime.tryParse(savedAt!);
      if (dt != null) {
        subtitle =
            'Saved ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bookmark,
              color: Color(0xFF3B82F6), size: 22),
        ),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary))
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => context
            .read<WorkoutBuilderBloc>()
            .add(RestoreWorkoutTemplateFromLocal(id)),
      ),
    );
  }
}

class _StartFromScratchCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StartFromScratchCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).startFromScratch,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context).buildCustomWorkout,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class _DraftsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DraftsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).myDrafts,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(AppLocalizations.of(context).continueEditingPlans,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyTemplates extends StatelessWidget {
  const _EmptyTemplates();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.bookmark_border, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).noSavedTemplatesYet,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).templatesSavedWillAppearHere,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
