import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { success, warning, error }

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
  }) {
    Color bgColor;
    IconData icon;
    
    switch (type) {
      case ToastType.success:
        bgColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        bgColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case ToastType.warning:
        bgColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 90.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
