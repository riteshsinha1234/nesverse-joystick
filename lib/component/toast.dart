import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nes_joystick/component/colors.dart';

class AppToast {
  static final FToast _fToast = FToast();
  static bool _initialized = false;

  static void init(BuildContext context) {
    _fToast.init(context);
    _initialized = true;
  }

  static void success(String message) {
    _show(message, successColor, Icons.check_circle_rounded);
  }

  static void error(String message) {
    _show(message, actionRed, Icons.error_rounded);
  }

  static void warning(String message) {
    _show(message, actionOrange, Icons.warning_rounded);
  }

  static void info(String message) {
    _show(message, actionBlue, Icons.info_rounded);
  }

  static void _show(String message, Color color, IconData icon) {
    if (!_initialized) return;

    _fToast.removeQueuedCustomToasts();

    _fToast.showToast(
      child: Container(
        width: 350,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
