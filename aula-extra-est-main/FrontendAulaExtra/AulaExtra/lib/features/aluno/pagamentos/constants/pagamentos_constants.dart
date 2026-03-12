import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Pagamentos (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/pagamentos/` para paddings e tipografia (título,
///   subtítulo, cabeçalhos de secção).
class PagamentosConstants {
  const PagamentosConstants._();

  /// Padding horizontal geral.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral.
  static const verticalPadding = 44.255;

  /// Estilo do título.
  static const titleStyle = TextStyle(
    fontSize: 41.081,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 49.298 / 41.081,
  );

  /// Estilo do subtítulo.
  static const subtitleStyle = TextStyle(
    fontSize: 21.91,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 32.865 / 21.91,
  );

  /// Estilo do título de secção (ex.: transações).
  static const sectionTitleStyle = TextStyle(
    fontSize: 27.388,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 38.343 / 27.388,
  );
}
