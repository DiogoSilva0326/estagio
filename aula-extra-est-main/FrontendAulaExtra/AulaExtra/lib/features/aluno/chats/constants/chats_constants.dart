import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Chats (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/chats/` para paddings, tipografia, estilos de cards,
///   cores de seleção e sombras.
class ChatsConstants {
  const ChatsConstants._();

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
  static const mobileSuccessColor = Color(0xFF12B76A);
  static const mobilePendingColor = Color(0xFFF79009);
  static const mobileDangerColor = Color(0xFFF04438);
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
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: mobileTextColor,
    height: 24 / 16,
  );

  static const mobileBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mobileMutedColor,
    height: 20 / 14,
  );

  static const mobileStatusStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
  );

  static const mobileBubbleIncomingColor = Color(0xFFFFFFFF);
  static const mobileBubbleOutgoingColor = Color(0xFFFF6B00);
  static const mobileBubbleIncomingBorderColor = Color(0xFFE5E7EB);
  static const mobileComposerBackgroundColor = Color(0xFFFFFFFF);
  static const mobileComposerHintColor = Color(0xFF98A2B3);
  static const mobileAvatarFallbackColor = Color(0xFFE5E7EB);

  /// Padding horizontal geral.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral.
  static const verticalPadding = 44.255;

  /// Estilo do título do ecrã.
  static const titleStyle = TextStyle(
    fontSize: 41.829,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 50.194 / 41.829,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 22.309,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.463 / 22.309,
  );

  /// Raio dos cards.
  static const cardRadius = 22.309;

  /// Espessura de bordas.
  static const borderWidth = 1.394;

  /// Borda suave (cards e separadores discretos).
  static const borderColorSoft = Color(0xFFF3F4F6);

  /// Borda padrão.
  static const borderColor = Color(0xFFE5E7EB);

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

  /// Fundo do item/conversa selecionada.
  static const selectedConversationBackground = Color(0xFFFFF7ED);

  /// Cor para ações/estado de risco (ex.: remover/bloquear).
  static const dangerRed = Color(0xFFFB2C36);

  /// Sombra padrão dos cards/listas.
  static const shadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 1.394),
      blurRadius: 4.183,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 1.394),
      blurRadius: 2.789,
      spreadRadius: -1.394,
    ),
  ];
}
