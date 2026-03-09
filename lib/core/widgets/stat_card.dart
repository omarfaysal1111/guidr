import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final double fontsize;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary, required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style:  TextStyle(
                fontSize: fontsize,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
