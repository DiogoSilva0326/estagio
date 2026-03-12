import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Registo**.
///
/// Onde é usado:
/// - Em `lib/features/register/` (ex.: `RegisterCard`, headers e botões do registo).
/// - Mantém gradientes, strokes e texto consistentes no fluxo de criação de conta.
class RegisterColors {
  /// Cor inicial do gradiente (hero/botões do registo).
  static const gradientStart = Color(0xFFFC9039);

  /// Cor final do gradiente (hero/botões do registo).
  static const gradientEnd = Color(0xFFF15C64);

  /// Texto principal (títulos e labels com maior destaque).
  static const textPrimary = Color(0xFF1E2939);

  /// Texto secundário (descrições, hints, apoio).
  static const textSecondary = Color(0xFF4A5565);

  /// Cor de contornos/divisores (inputs, cards, borders suaves).
  static const stroke = Color(0xFFD1D5DC);
}
