import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void showSuccess({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      snackbarDuration: const Duration(milliseconds: 3200),
      builder: (c) => ToastCard(
        color: const Color(0xFF10B981),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w400,
            fontSize: 12.5,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
      ),
    ).show(ctx);
  }

  static void showError({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      snackbarDuration: const Duration(milliseconds: 3800),
      builder: (c) => ToastCard(
        color: const Color(0xFFEF4444),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w400,
            fontSize: 12.5,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
      ),
    ).show(ctx);
  }

  static void showWarning({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      snackbarDuration: const Duration(milliseconds: 3500),
      builder: (c) => ToastCard(
        color: const Color(0xFFF59E0B),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w400,
            fontSize: 12.5,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
      ),
    ).show(ctx);
  }

  static void showInfo({
    BuildContext? context,
    required String title,
    required String message,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      snackbarDuration: const Duration(milliseconds: 3200),
      builder: (c) => ToastCard(
        color: const Color(0xFF4B96E6),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w400,
            fontSize: 12.5,
            fontFamily: 'Airbnb Cereal App',
          ),
        ),
      ),
    ).show(ctx);
  }
}
