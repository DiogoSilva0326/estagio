import 'package:flutter/material.dart';

/// Design tokens e estilos do ecrã de **Calendário (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/calendario/` para paddings, tipografia, cores de tabs
///   e estilo de cards do calendário.
class CalendarioConstants {
  const CalendarioConstants._();

  /// Padding horizontal geral do ecrã.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral do ecrã.
  static const verticalPadding = 44.255;

  /// Estilo do título principal.
  static const titleStyle = TextStyle(
    fontSize: 42.008,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 50.41 / 42.008,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 22.404,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.607 / 22.404,
  );

  /// Cor do tab ativo.
  static const activeTabColor = Color(0xFFFF6B00);

  /// Cor do tab inativo.
  static const inactiveTabColor = Color(0xFF6A7282);

  /// Cor do divisor/separador.
  static const dividerColor = Color(0xFFE5E7EB);

  /// Cor de borda do card.
  static const cardBorderColor = Color(0xFFF3F4F6);

  /// Sombra do card (elevação suave).
  static const cardShadow = [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.4), blurRadius: 4.201),
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.4), blurRadius: 2.801),
  ];

  /// Raio do card.
  static const cardRadius = 22.404;

  /// Espessura da borda do card.
  static const cardBorderWidth = 1.4;
}
