import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';

class TraineeCard extends StatelessWidget {
  final Trainee trainee;
  final bool isSelected;
  final VoidCallback onTap;

  const TraineeCard({
    super.key,
    required this.trainee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final adherenceColor = trainee.adherence >= 80
        ? AppColors.success
        : trainee.adherence >= 50
            ? AppColors.warning
            : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildCheckbox(),
            const SizedBox(width: 12),
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            _buildAdherence(adherenceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
      child: Text(
        trainee.avatar,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trainee.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          '${trainee.goal} · ${trainee.level}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAdherence(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${trainee.adherence}%',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
        const Text('adherence', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}