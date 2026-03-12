import 'package:flutter/material.dart';

/// Design tokens do ecrã **Minhas Áreas (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/areas_aluno/` para gradientes, paddings, tipografia,
///   espaçamento de chips/filtros e grelha de cartões.
class AreasAlunoConstants {
  const AreasAlunoConstants._();

  /// Cor inicial do gradiente laranja (accent).
  static const orangeStart = Color(0xFFFF6B00);

  /// Cor final do gradiente laranja (accent).
  static const orangeEnd = Color(0xFFFF9966);

  /// Gradiente laranja usado em elementos de destaque.
  static const orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orangeStart, orangeEnd],
  );

  /// Padding horizontal geral do ecrã.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral do ecrã.
  static const verticalPadding = 44.255;

  /// Cor do título principal.
  static const titleColor = Color(0xFF101828);

  /// Cor de labels e texto secundário.
  static const labelColor = Color(0xFF4A5565);

  /// Estilo do título.
  static const titleStyle = TextStyle(
    fontSize: 41.489,
    fontWeight: FontWeight.w500,
    color: titleColor,
    height: 49.787 / 41.489,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 22.128,
    fontWeight: FontWeight.w400,
    color: labelColor,
    height: 33.191 / 22.128,
  );

  /// Espaço entre chips/filtros.
  static const filterChipGap = 16.0;

  /// Espaçamento horizontal entre cartões da grelha.
  static const gridCrossAxisSpacing = 33.191;

  /// Espaçamento vertical entre cartões da grelha.
  static const gridMainAxisSpacing = 33.191;

  /// Altura/extent principal de cada item da grelha.
  static const gridMainAxisExtent = 309.787;

  /// Cor da borda do botão “Adicionar área”.
  static const addAreaButtonBorderColor = Color(0xFFD1D5DC);

  /// Espessura da borda do botão “Adicionar área”.
  static const addAreaButtonBorderWidth = 2.766;

  /// Raio do botão “Adicionar área”.
  static const addAreaButtonRadius = 22.128;

  /// Tamanho do ícone no botão “Adicionar área”.
  static const addAreaIconSize = 27.66;

  /// Estilo do texto do botão “Adicionar área”.
  static const addAreaTextStyle = TextStyle(
    fontSize: 22.128,
    fontWeight: FontWeight.w400,
    color: labelColor,
    height: 33.191 / 22.128,
  );
}
