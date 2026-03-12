import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Avaliações (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/avaliacoes/` para paddings, tipografia e espaçamentos
///   das secções (média, lista de reviews, etc.).
class AvaliacoesConstants {
  const AvaliacoesConstants._();

  /// Padding horizontal geral do ecrã.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral do ecrã.
  static const verticalPadding = 44.255;

  /// Estilo do título principal.
  static const titleStyle = TextStyle(
    fontSize: 41.221,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 49.466 / 41.221,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 21.985,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 32.977 / 21.985,
  );

  /// Estilo do título de secção (ex.: listas/estatísticas).
  static const sectionTitleStyle = TextStyle(
    fontSize: 27.481,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 38.473 / 27.481,
  );

  /// Espaçamento pequeno entre elementos.
  static const gapSmall = 10.992;

  /// Espaçamento grande (respiro entre blocos principais).
  static const gapLarge = 43.969;

  /// Espaçamento entre secções.
  static const gapSection = 21.985;

  /// Espaço após o bloco de estatísticas.
  static const gapAfterStats = 32.977;
}
