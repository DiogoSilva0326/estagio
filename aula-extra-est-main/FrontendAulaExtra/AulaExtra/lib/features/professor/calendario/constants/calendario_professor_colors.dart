import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Calendário (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/calendario/` para fundo, tabs, cards, botões e badges.
class CalendarioProfessorColors {
  const CalendarioProfessorColors._();

  /// Fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título.
  static const Color title = Color(0xFF1E2939);

  /// Cor do texto normal.
  static const Color text = Color(0xFF364153);

  /// Cor do texto secundário.
  static const Color muted = Color(0xFF6A7282);

  /// Fundo das tabs.
  static const Color tabsBackground = Color(0xFFF3F4F6);

  /// Borda dos cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Texto do tab selecionado.
  static const Color tabSelectedText = Color(0xFF0A0A0A);

  /// Gradiente do botão “Adicionar”.
  static const Color addGradientTop = Color(0xFFFF6B00);
  static const Color addGradientBottom = Color(0xFFFF9966);

  /// Cor do botão “Entrar” (ação primária).
  static const Color enterButton = Color(0xFF155DFC);

  /// Cor do botão “Cancelar”.
  static const Color cancelRed = Color(0xFFFB2C36);

  /// Cores de badges (usadas no avatar/estado da aula).
  static const Color badgeBlue = Color(0xFF2B7FFF);
  static const Color badgeGreen = Color(0xFF00C950);
  static const Color badgeOrange = Color(0xFFFF6900);
}
