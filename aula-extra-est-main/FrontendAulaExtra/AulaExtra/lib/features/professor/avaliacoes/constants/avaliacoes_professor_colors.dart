import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Avaliações (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/avaliacoes/` para fundo, cards, gradientes de
///   resumo/avatar e cor das estrelas.
class AvaliacoesProfessorColors {
  const AvaliacoesProfessorColors._();

  /// Fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título.
  static const Color title = Color(0xFF1E2939);

  /// Texto normal.
  static const Color text = Color(0xFF364153);

  /// Texto secundário.
  static const Color muted = Color(0xFF6A7282);

  /// Borda dos cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Gradiente do cartão de resumo (média/contagens).
  static const Color summaryGradientTop = Color(0xFFFF6B00);
  static const Color summaryGradientBottom = Color(0xFFFF9966);

  /// Gradiente do avatar (iniciais).
  static const Color avatarGradientTop = Color(0xFF51A2FF);
  static const Color avatarGradientBottom = Color(0xFF155DFC);

  /// Cor das estrelas de rating.
  static const Color star = Color(0xFFFF6B00);
}
