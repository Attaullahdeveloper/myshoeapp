import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ─── Primary Palette ────────────────────────────────
  static const Color primary = Color(0xFFC8A951); // Premium gold
  static const Color primaryLight = Color(0xFFE8C96A);
  static const Color primaryDark = Color(0xFF9E7F2E);

  // ─── Background ─────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D);     // Deep black
  static const Color backgroundAlt = Color(0xFF141414);   // Slightly lighter
  static const Color surface = Color(0xFF1A1A1A);         // Card surface
  static const Color surfaceAlt = Color(0xFF222222);      // Elevated surface

  // Onboarding
  static const Color onboardingBg = Color(0xFFF9F9F9);
  static const Color onboardingTitle = Color(0xFF1A2530);
  static const Color onboardingSub = Color(0xFF707B81);
  static const Color onboardingBtn = Color(0xFF5B9EE1);

  // ─── Text ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF606060);

  // ─── Accent / Status ─────────────────────────────────
  static const Color accent = Color(0xFFC8A951);
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF4CAF50);

  // ─── Standard ────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF888888);
  static const Color divider = Color(0xFF2A2A2A);

  // ─── Gradients ───────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0D0D),
      Color(0xFF1A1208),
      Color(0xFF0D0D0D),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8C96A),
      Color(0xFFC8A951),
      Color(0xFF9E7F2E),
    ],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x40C8A951),
      Color(0x00C8A951),
    ],
  );

  // ─── Neon Palette ────────────────────────────────────
  static const Color neonYellow = Color(0xFFFFD54F);  // Warm vibrant yellow
  static const Color neonRed = Color(0xFFFF3366);     // Vivid neon pink-red
  static const Color neonBlue = Color(0xFF00E5FF);    // Bright cyan-blue
  static const Color neonWhite = Color(0xFFFFFFFF);   // Clean white glow
  
  static const Color neonGlowYellow = Color(0x33FFD54F);
  static const Color neonGlowRed = Color(0x33FF3366);
  static const Color neonGlowBlue = Color(0x3300E5FF);
  
  // ─── Figma Theme / Custom Shoe Colors ─────────────────
  static const Color neonTurquoise = Color(0xFF00E4C0); // Vibrant figma-style teal-cyan
  static const Color neonShoeRed = Color(0xFFFF1A40);   // Bold red shoe base
  static const Color neonGoldFlame = Color(0xFFFFD000); // Gold flame color
  
  static const Color neonGlowTurquoise = Color(0x3800E4C0);
  static const Color neonGlowShoeRed = Color(0x38FF1A40);
  static const Color neonGlowGoldFlame = Color(0x38FFD000);
  
  // ─── Premium Light Background Gradient ────────────────
  static const LinearGradient premiumLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAF8F5), // Soft clean warm white
      Color(0xFFF0EAE1), // Smooth sandy alabaster
      Color(0xFFE5DCD0), // Elegant light warm grey
    ],
  );

  // ─── Figma Teal Splash Gradient ────────────────────────
  static const LinearGradient figmaSplashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF006663), // Vibrant deep teal
      Color(0xFF00403E), // Dark premium teal
    ],
  );
}
