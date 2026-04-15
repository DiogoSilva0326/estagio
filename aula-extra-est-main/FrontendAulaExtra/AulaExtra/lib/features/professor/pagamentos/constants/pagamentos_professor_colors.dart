import 'package:flutter/material.dart';

/// Paleta de cores da área de **Pagamentos** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/pagamentos/` (resumo, tabela de movimentos e botão de levantamento)
/// - Badges de estado (Pago / Pendente) e cartões-resumo por categoria.
class PagamentosProfessorColors {
  const PagamentosProfessorColors._();

  /// Cor base do fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título principal.
  static const Color title = Color(0xFF1E2939);

  /// Cor do texto normal.
  static const Color text = Color(0xFF0A0A0A);

  /// Borda base de cartões e tabela.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Fundo do cabeçalho da tabela.
  static const Color tableHeaderBackground = Color(0xFFF9FAFB);

  /// Fundo do badge quando o pagamento está “Pago”.
  static const Color badgePaidBackground = Color(0xFF00C950);

  /// Fundo do badge quando o pagamento está “Pendente”.
  static const Color badgePendingBackground = Color(0xFFFEF9C2);

  /// Cor do texto do badge “Pendente”.
  static const Color badgePendingText = Color(0xFF894B00);

  /// Fundo do badge quando o pagamento foi devolvido.
  static const Color badgeRefundedBackground = Color(0xFFFEE2E2);

  /// Cor do texto do badge “Devolvido”.
  static const Color badgeRefundedText = Color(0xFFB42318);

  /// Cor do valor a verde (ex.: ganhos/entradas).
  static const Color valueGreenText = Color(0xFF00A63E);

  /// Gradiente (topo) do botão “Levantar”.
  static const Color withdrawGradientTop = Color(0xFFFF6B00);

  /// Gradiente (base) do botão “Levantar”.
  static const Color withdrawGradientBottom = Color(0xFFFF9966);

  /// Gradiente verde (topo) em cartões-resumo.
  static const Color summaryGreenTop = Color(0xFF00C950);

  /// Gradiente verde (base) em cartões-resumo.
  static const Color summaryGreenBottom = Color(0xFF00A63E);

  /// Gradiente laranja (topo) em cartões-resumo.
  static const Color summaryOrangeTop = Color(0xFFFF6B00);

  /// Gradiente laranja (base) em cartões-resumo.
  static const Color summaryOrangeBottom = Color(0xFFFF9966);

  /// Gradiente azul (topo) em cartões-resumo.
  static const Color summaryBlueTop = Color(0xFF2B7FFF);

  /// Gradiente azul (base) em cartões-resumo.
  static const Color summaryBlueBottom = Color(0xFF155DFC);
}
