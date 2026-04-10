import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/trainee_health_history.dart';

void showHealthTrainingHistorySheet(BuildContext context, TraineeHealthHistory data) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _HealthTrainingHistorySheetBody(data: data),
  );
}

class _HealthTrainingHistorySheetBody extends StatelessWidget {
  final TraineeHealthHistory data;

  const _HealthTrainingHistorySheetBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: maxH,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Health & Training History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _HistoryCard(
                        label: 'GOAL',
                        value: data.goal,
                        icon: Icons.track_changes_rounded,
                        accent: const Color(0xFF0D9488),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'TRAINING EXPERIENCE',
                        value: data.trainingExperience,
                        icon: Icons.fitness_center_rounded,
                        accent: const Color(0xFF14B8A6),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'PREVIOUS TRAINING',
                        value: data.previousTraining,
                        icon: Icons.history_rounded,
                        accent: const Color(0xFF7C3AED),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'REASON FOR STOPPING',
                        value: data.reasonForStopping,
                        icon: Icons.warning_amber_rounded,
                        accent: const Color(0xFFD97706),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'DISEASES / CONDITIONS',
                        value: data.diseasesOrConditions,
                        icon: Icons.monitor_heart_outlined,
                        accent: const Color(0xFFDC2626),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'ALLERGIES',
                        value: data.allergies,
                        icon: Icons.warning_amber_rounded,
                        accent: const Color(0xFFCA8A04),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'INJURIES',
                        value: data.injuries,
                        icon: Icons.shield_outlined,
                        accent: const Color(0xFFB91C1C),
                      ),
                      const SizedBox(height: 12),
                      _HistoryCard(
                        label: 'MEDICATIONS',
                        value: data.medications,
                        icon: Icons.description_outlined,
                        accent: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _HistoryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
