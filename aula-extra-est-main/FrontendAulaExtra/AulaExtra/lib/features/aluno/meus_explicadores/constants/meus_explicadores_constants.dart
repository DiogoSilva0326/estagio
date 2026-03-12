import 'package:flutter/material.dart';

/// Design tokens do ecrã **Meus Explicadores (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/meus_explicadores/` para paddings, tipografia e
///   dimensões/spacing da grelha de cartões de explicadores.
class MeusExplicadoresConstants {
  const MeusExplicadoresConstants._();

  /// Padding horizontal geral.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral.
  static const verticalPadding = 44.255;

  /// Estilo do título.
  static const titleStyle = TextStyle(
    fontSize: 41.489,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 49.787 / 41.489,
  );

  /// Estilo do subtítulo.
  static const subtitleStyle = TextStyle(
    fontSize: 22.128,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.191 / 22.128,
  );

  /// Espaço extra no topo do conteúdo.
  static const topSpacer = 8.0;

  /// Espaço entre título e subtítulo.
  static const titleSubtitleGap = 11.064;

  /// Espaço após o subtítulo.
  static const afterSubtitleGap = 33.0;

  /// Largura do card de explicador.
  static const cardWidth = 305.182;

  /// Espaçamento entre cards na grelha.
  static const gridSpacing = 33.191;

  /// Altura/extent do item de grelha (para manter proporção do card).
  static const gridMainAxisExtent = 557.062;
}
