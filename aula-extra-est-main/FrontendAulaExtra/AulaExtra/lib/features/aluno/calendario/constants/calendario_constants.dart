import 'package:flutter/material.dart';

/// Design tokens e estilos do ecrã de **Calendário (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/calendario/` para paddings, tipografia, cores de tabs
///   e estilo de cards do calendário.
class CalendarioConstants {
  const CalendarioConstants._();

  static const backgroundColor = Color(0xFFF9F9F9);

  static const mobileHorizontalPadding = 16.0;
  static const mobileVerticalPadding = 16.0;
  static const mobileSectionSpacing = 16.0;
  static const mobileCardRadius = 20.0;
  static const mobileChipRadius = 999.0;
  static const mobilePrimaryButtonRadius = 14.0;
  static const mobileSecondaryButtonRadius = 14.0;
  static const mobileBorderColor = Color(0xFFE9EAEB);
  static const mobileMutedColor = Color(0xFF667085);
  static const mobileTextColor = Color(0xFF101828);
  static const mobileSurfaceColor = Colors.white;
  static const mobileSoftSurface = Color(0xFFF9FAFB);
  static const mobileTodaySurface = Color(0xFFFFF7ED);
  static const mobileDangerColor = Color(0xFFFB2C36);
  static const mobileSuccessColor = Color(0xFF00C950);
  static const mobilePendingColor = Color(0xFFF59E0B);
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
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: mobileTextColor,
    height: 28 / 20,
  );

  static const mobileCardSubtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileMetaStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: mobileMutedColor,
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
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 1.4),
      blurRadius: 4.201,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 1.4),
      blurRadius: 2.801,
    ),
  ];

  /// Raio do card.
  static const cardRadius = 22.404;

  /// Espessura da borda do card.
  static const cardBorderWidth = 1.4;
}
