import 'package:flutter/material.dart';

class DisciplinasMobileLayout {
  const DisciplinasMobileLayout._();

  static const double pageHorizontalPadding = 20;
  static const double contentSpacing = 24;
  static const double cardRadius = 24;
  static const double chipRadius = 999;

  static const Color pageBackground = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF364153);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accentOrange = Color(0xFFFC9039);
  static const Color accentPink = Color(0xFFF15C64);
  static const Color accentBlue = Color(0xFF3B94EF);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
  );

  static const LinearGradient ratingsGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
  );
}
