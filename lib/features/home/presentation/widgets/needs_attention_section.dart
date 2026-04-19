// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/needs_attention/domain/entities/attention_item.dart';

/// A reusable section that displays items needing coach attention.
/// Accepts dynamic data from the API via [items].
class NeedsAttentionSection extends StatelessWidget {
  final List<AttentionItem> items;
  final VoidCallback? onViewAll;
  final void Function(AttentionItem)? onItemTap;

  const NeedsAttentionSection({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  Color _colorForType(String alertType) {
    switch (alertType) {
      case 'nutrition':
        return AppColors.warning;
      case 'missed':
      case 'noLogin':
      case 'plateau':
      default:
        return AppColors.error;
    }
  }

  Color _lightColorForType(String alertType) {
    switch (alertType) {
      case 'nutrition':
        return AppColors.warningLight;
      default:
        return AppColors.errorLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.circle, color: AppColors.error, size: 10),
                SizedBox(width: 8),
                Text(
                  'Needs Attention',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty)
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'View all',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No items need attention right now.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...items.map(
            (item) => _AttentionCard(
              item: item,
              color: _colorForType(item.alertType),
              lightColor: _lightColorForType(item.alertType),
              onTap: onItemTap != null ? () => onItemTap!(item) : null,
            ),
          ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final AttentionItem item;
  final Color color;
  final Color lightColor;
  final VoidCallback? onTap;

  const _AttentionCard({
    required this.item,
    required this.color,
    required this.lightColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = item.clientName.isNotEmpty
        ? item.clientName.substring(0, 1).toUpperCase()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.clientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
