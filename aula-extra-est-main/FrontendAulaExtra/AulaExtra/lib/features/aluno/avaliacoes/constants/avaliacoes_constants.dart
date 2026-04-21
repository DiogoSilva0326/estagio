import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Avaliações (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/avaliacoes/` para paddings, tipografia e espaçamentos
///   das secções (média, lista de reviews, etc.).
class AvaliacoesConstants {
  const AvaliacoesConstants._();

  static const backgroundColor = Color(0xFFF9F9F9);
  static const mobileHorizontalPadding = 16.0;
  static const mobileVerticalPadding = 16.0;
  static const mobileSectionSpacing = 16.0;
  static const mobileCardRadius = 20.0;
  static const mobileChipRadius = 999.0;
  static const mobileBorderColor = Color(0xFFE9EAEB);
  static const mobileSurfaceColor = Colors.white;
  static const mobileMutedColor = Color(0xFF667085);
  static const mobileTextColor = Color(0xFF101828);
  static const mobileSoftSurface = Color(0xFFF9FAFB);
  static const mobilePrimaryColor = Color(0xFFFF6B00);
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

  static const mobileCardSubtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF364153),
    height: 20 / 14,
  );

  static const mobileMetaStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6A7282),
    height: 18 / 13,
  );

  static const mobileValueStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: mobileTextColor,
    height: 20 / 14,
  );

  static const mobileTabStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
  );

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
