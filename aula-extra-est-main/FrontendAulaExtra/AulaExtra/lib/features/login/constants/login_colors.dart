import 'package:flutter/material.dart';

/// Paleta de cores usada no fluxo de **Login**.
///
/// Onde é usado:
/// - Em `lib/features/login/pages/login_screen.dart` e widgets em `lib/features/login/widgets/`.
/// - Centraliza cores para manter o design consistente (gradientes, texto e bordas).
class LoginColors {
  /// Cor inicial do gradiente (topo).
  static const gradientStart = Color(0xFFFC9039);

  /// Cor final do gradiente (base).
  static const gradientEnd = Color(0xFFF15C64);

  /// Cor do texto principal (títulos, labels em destaque).
  static const textPrimary = Color(0xFF1E2939);

  /// Cor do texto secundário (subtítulos, texto menos importante).
  static const textSecondary = Color(0xFF4A5565);

  /// Cor de contorno/borda (inputs, divisórias, strokes).
  static const stroke = Color(0xFFD1D5DC);
}
