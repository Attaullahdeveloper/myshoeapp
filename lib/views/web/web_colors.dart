import 'package:flutter/material.dart';

class WebColors {
  WebColors._();

  static const Color bg = Color(0xFF090C10);
  static const Color surface = Color(0xFF12161F);
  static const Color surfaceElevated = Color(0xFF181E2A);
  static const Color surfaceHover = Color(0xFF1E2638);
  static const Color border = Color(0xFF262E3D);
  static const Color borderSubtle = Color(0x1FFFFFFF);

  static const Color gold = Color(0xFFE5C07B);
  static const Color goldLight = Color(0xFFF3D99E);
  static const Color goldDark = Color(0xFFC8A951);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color emerald = Color(0xFF10B981);
  static const Color red = Color(0xFFFF4757);
  static const Color purple = Color(0xFF8B5CF6);

  static const Color textMain = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color textDim = Color(0xFF5A6270);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2638),
      Color(0xFF10141D),
      Color(0xFF090C10),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3D99E),
      Color(0xFFE5C07B),
      Color(0xFFB58F38),
    ],
  );

  static const LinearGradient cardGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AE5C07B),
      Color(0x00000000),
    ],
  );
}
