import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Arquivos (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/arquivos/` para paddings, tipografia e espaçamentos
///   de secções (ex.: ficheiros recentes).
class ArquivosConstants {
  const ArquivosConstants._();

  /// Padding horizontal geral.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral.
  static const verticalPadding = 44.255;

  /// Estilo do título principal.
  static const titleStyle = TextStyle(
    fontSize: 41.797,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 50.157 / 41.797,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 22.292,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.438 / 22.292,
  );

  /// Estilo do título de secção.
  static const sectionTitleStyle = TextStyle(
    fontSize: 27.865,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 39.011 / 27.865,
  );

  /// Espaçamento pequeno entre elementos.
  static const gapSmall = 11.146;

  /// Espaçamento grande entre blocos.
  static const gapLarge = 44.584;

  /// Espaçamento entre secções.
  static const gapSection = 22.292;
}
