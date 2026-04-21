import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Arquivos (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/arquivos/` para paddings, tipografia e espaçamentos
///   de secções (ex.: ficheiros recentes).
class ArquivosConstants {
  const ArquivosConstants._();

  static const backgroundColor = Color(0xFFF9F9F9);
  static const mobileHorizontalPadding = 16.0;
  static const mobileVerticalPadding = 16.0;
  static const mobileSectionSpacing = 16.0;
  static const mobileCardRadius = 20.0;
  static const mobileBorderColor = Color(0xFFE9EAEB);
  static const mobileSurfaceColor = Colors.white;
  static const mobileMutedColor = Color(0xFF667085);
  static const mobileTextColor = Color(0xFF101828);
  static const mobileSoftSurface = Color(0xFFF9FAFB);
  static const mobileShadow = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.08),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const mobileTitleStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: mobileTextColor,
    height: 36 / 30,
  );

  static const mobileSubtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileSectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: mobileTextColor,
    height: 28 / 20,
  );

  static const mobileCardTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: mobileTextColor,
    height: 24 / 18,
  );

  static const mobileBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileMetaLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: mobileMutedColor,
    height: 18 / 13,
  );

  static const mobileMetaValueStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: mobileTextColor,
    height: 20 / 14,
  );

  static const mobileStatLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileStatValueStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: mobileTextColor,
    height: 20 / 14,
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
  );

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
