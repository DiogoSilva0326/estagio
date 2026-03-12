import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Perfil (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/perfil/` para fundo, texto, bordas, gradiente
///   principal, preenchimento de inputs e badges.
class PerfilProfessorColors {
  const PerfilProfessorColors._();

  /// Fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título.
  static const Color title = Color(0xFF1E2939);

  /// Cor do texto normal.
  static const Color text = Color(0xFF364153);

  /// Cor do texto secundário.
  static const Color muted = Color(0xFF4A5565);

  /// Borda de cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Gradiente principal (ex.: botão “Guardar”).
  static const Color primaryGradientTop = Color(0xFFFF6B00);
  static const Color primaryGradientBottom = Color(0xFFFF9966);

  /// Fill de inputs (campos) no perfil.
  static const Color inputFill = Color(0xFFF3F3F5);

  /// Cor de badge/realce azul.
  static const Color badgeBlue = Color(0xFF2B7FFF);

  /// Cor do texto de aviso/estrela (ex.: rating/alerta).
  static const Color warningStarText = Color(0xFFD08700);
}
