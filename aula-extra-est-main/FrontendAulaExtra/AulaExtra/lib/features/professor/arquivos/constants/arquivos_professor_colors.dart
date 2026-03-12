import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Arquivos (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/arquivos/` para fundo, cards, pesquisa e badges
///   de tipos de ficheiro.
class ArquivosProfessorColors {
  const ArquivosProfessorColors._();

  /// Fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título.
  static const Color title = Color(0xFF1E2939);

  /// Texto secundário (descrições/labels).
  static const Color textSecondary = Color(0xFF6A7282);

  /// Hint text (placeholders).
  static const Color hintText = Color(0xFF717182);

  /// Fundo dos cards.
  static const Color cardBackground = Colors.white;

  /// Borda dos cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Fill do input de pesquisa.
  static const Color searchFill = Color(0xFFF3F3F5);

  /// Gradiente do botão/CTA de upload.
  static const Color uploadGradientTop = Color(0xFFFF6B00);
  static const Color uploadGradientBottom = Color(0xFFFF9966);

  /// Fundos (badges) por tipo de ficheiro.
  static const Color fileTypeRedBg = Color(0xFFFFE2E2);
  static const Color fileTypeOrangeBg = Color(0xFFFFEDD4);
  static const Color fileTypeBlueBg = Color(0xFFDBEAFE);
  static const Color fileTypeGreenBg = Color(0xFFDCFCE7);
}
