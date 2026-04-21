import 'package:flutter/material.dart';

class ExplicadoresMobileLayout {
  const ExplicadoresMobileLayout._();

  static const double maxWidth = 373;
  static const double pageHorizontalPadding = 20;
  static const double contentSpacing = 24;
  static const double heroTopPadding = 32;
  static const double heroBottomPadding = 24;
  static const double heroButtonHeight = 56;
  static const double sectionCardRadius = 20;
  static const double tutorCardRadius = 20;

  static const Color pageBackground = Color(0xFFF9F9F9);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF364153);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color accentOrange = Color(0xFFFC9039);
  static const Color accentPink = Color(0xFFF15C64);
  static const Color border = Color(0xFFE5E7EB);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
  );
}
