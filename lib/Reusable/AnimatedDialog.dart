import 'package:flutter/material.dart';

class AnimatedDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    Color backgroundColor = Colors.green,
    IconData icon = Icons.check_circle,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 10,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 500 + (300 * value).round()),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, iconValue, child) {
                          return Transform.scale(
                            scale: iconValue,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor.withOpacity(0.1),
                                border: Border.all(
                                  color: backgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Transform.rotate(
                                angle: iconValue * 2 * 3.14159,
                                child: Icon(
                                  icon,
                                  color: backgroundColor,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Animated title
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 600 + (200 * value).round()),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, titleValue, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - titleValue)),
                            child: Opacity(
                              opacity: titleValue,
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: backgroundColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Animated message
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 700 + (200 * value).round()),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, messageValue, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - messageValue)),
                            child: Opacity(
                              opacity: messageValue,
                              child: Text(
                                message,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Animated button
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800 + (200 * value).round()),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, buttonValue, child) {
                          return Transform.scale(
                            scale: buttonValue,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onPressed?.call();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backgroundColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Success!',
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      onPressed: onPressed,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Error',
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      onPressed: onPressed,
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String title = 'Information',
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      onPressed: onPressed,
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String message,
    String title = 'Warning',
    VoidCallback? onPressed,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      onPressed: onPressed,
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
    IconData icon = Icons.help_outline,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 10,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 500 + (300 * value).round()),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, iconValue, child) {
                          return Transform.scale(
                            scale: iconValue,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: confirmColor.withOpacity(0.1),
                                border: Border.all(
                                  color: confirmColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: confirmColor,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Title and message
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: confirmColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: confirmColor),
                              ),
                              child: Text(
                                cancelText,
                                style: TextStyle(
                                  color: confirmColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: confirmColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
