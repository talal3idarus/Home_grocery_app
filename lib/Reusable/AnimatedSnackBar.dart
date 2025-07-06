import 'package:flutter/material.dart';

class AnimatedSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.green,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }
}
