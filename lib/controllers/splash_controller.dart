import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/onboarding/onboarding_view.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  // ── Animation Controllers ───────────────────────────────────────
  late AnimationController entranceController;

  // ── Entrance Animations ──────────────────────────────────────────
  late Animation<double> bgOpacity;
  late Animation<double> shoeOpacity;
  late Animation<double> shoeRise;
  late Animation<double> shoeTilt;
  late Animation<double> shadowOpacity;
  late Animation<double> shadowScale;
  late Animation<double> textUnfurl;
  late Animation<double> textOpacity;
  late Animation<double> textScale;
  late Animation<double> textSlideY;
  late Animation<double> textLetterSpacing;

  // ── Reactive State ──────────────────────────────────────────────
  final RxBool isEntranceCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
  }

  @override
  void onReady() {
    super.onReady();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // 1. Entrance Controller (controls staggered entries, slowed down to 4.5s for premium feel)
    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // ── Staggered Animations definition ──
    bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    shoeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.12, 0.25, curve: Curves.easeIn),
      ),
    );

    // Normalized progress factor (0.0 to 1.0) for shoe fall
    shoeRise = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.12, 0.60, curve: Curves.bounceOut),
      ),
    );

    // Shoe tilted during fall (-0.35 rad) and straightening out on impact
    shoeTilt = Tween<double>(begin: -0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.12, 0.60, curve: Curves.easeOut),
      ),
    );

    // Shadow opacity grows as shoe falls closer to ground
    shadowOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.12, 0.60, curve: Curves.easeOut),
      ),
    );

    // Shadow scale grows as shoe falls closer to ground
    shadowScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.12, 0.60, curve: Curves.easeOut),
      ),
    );

    // Text ribbon horizontal unfurling
    textUnfurl = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.65, 0.88, curve: Curves.easeInOutCubic),
      ),
    );

    // Big text opacity fades in alongside the ribbon unfurl
    textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.65, 0.88, curve: Curves.easeIn),
      ),
    );

    // Subtle scale pop and vertical offset for text as it settles
    textScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.70, 0.92, curve: Curves.easeOutBack),
      ),
    );

    textSlideY = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.70, 0.92, curve: Curves.easeOut),
      ),
    );

    // Dynamic Tracking / Letter Spacing expansion-to-contraction
    textLetterSpacing = Tween<double>(begin: 16.0, end: 5.5).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.65, 0.92, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimationSequence() {
    entranceController.forward().then((_) {
      isEntranceCompleted.value = true;
      // Delay navigation slightly so the splash screen's final state settles
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.off(
          () => const OnboardingView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200),
        );
      });
    });
  }

  @override
  void onClose() {
    entranceController.dispose();
    super.onClose();
  }
}
