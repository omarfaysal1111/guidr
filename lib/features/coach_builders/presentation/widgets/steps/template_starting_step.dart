import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/workout_builder_bloc.dart';
import '../../bloc/workout_builder_event.dart';

class TemplateStartingStep extends StatelessWidget {
  const TemplateStartingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StartFromScratchCard(
          onTap: () =>
              context.read<WorkoutBuilderBloc>().add(const SetStep(3)),
        ),
        const SizedBox(height: 16),
        _DraftsCard(
          onTap: () =>
              context.read<WorkoutBuilderBloc>().add(const SetStep(3)),
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'SAVED TEMPLATES'),
        const SizedBox(height: 12),
        const _EmptyTemplates(),
      ],
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start from Scratch',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Build a completely custom workout',
                      style:
                          TextStyle(fontSize: 14, color: Colors.white70)),
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Drafts',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Continue editing saved plans',
                      style: TextStyle(
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
          const Text('No saved templates yet',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Templates you save will appear here',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textMuted)),
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
