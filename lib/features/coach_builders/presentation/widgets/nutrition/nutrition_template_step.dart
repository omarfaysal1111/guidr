import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';

class NutritionTemplateStep extends StatelessWidget {
  const NutritionTemplateStep({super.key});

  static const _templates = [
    {
      'id': '1',
      'title': 'High Protein — Muscle Building',
      'difficulty': 'Intermediate',
      'diffColor': AppColors.success,
      'desc': 'High protein · ~2200 kcal',
      'tags': ['Chicken breast', 'Eggs', 'Greek yogurt', 'Whey', 'Macros'],
      'count': '4 meals',
    },
    {
      'id': '2',
      'title': 'Low Carb — Fat Loss',
      'difficulty': 'Advanced',
      'diffColor': AppColors.error,
      'desc': 'Low carb · ~1800 kcal',
      'tags': ['Avocado', 'Salmon', 'Leafy greens', 'Nuts', 'Macros'],
      'count': '4 meals',
    },
    {
      'id': '3',
      'title': 'Balanced — Maintenance',
      'difficulty': 'Beginner',
      'diffColor': Color(0xFF3B82F6),
      'desc': 'Balanced macros · ~2000 kcal',
      'tags': ['Whole grains', 'Lean protein', 'Vegetables', 'Fruits', 'Macros'],
      'count': '5 meals',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StartFromScratch(
          onTap: () => context
              .read<NutritionBuilderBloc>()
              .add(const NutritionSetStep(3)),
        ),
        const SizedBox(height: 16),
        _DraftsCard(
          onTap: () => context
              .read<NutritionBuilderBloc>()
              .add(const NutritionSetStep(3)),
        ),
        const SizedBox(height: 24),
        const Text('SAVED TEMPLATES',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ..._templates.map((t) => _TemplateCard(template: t)),
      ],
    );
  }
}

class _StartFromScratch extends StatelessWidget {
  final VoidCallback onTap;
  const _StartFromScratch({required this.onTap});

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
                  Text('Build a completely custom nutrition plan',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

class _TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    final diffColor = template['diffColor'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(template['title'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(template['difficulty'] as String,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: diffColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(template['desc'] as String,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (template['tags'] as List<String>)
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tag,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(template['count'] as String,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.read<NutritionBuilderBloc>().add(
                  NutritionApplyTemplate(template['id'] as String)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Use template →',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
