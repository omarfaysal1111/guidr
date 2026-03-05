import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  final double max;
  final Color color;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.color = AppColors.primary,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = (value / max).clamp(0.0, 1.0);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              width: constraints.maxWidth * pct,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
