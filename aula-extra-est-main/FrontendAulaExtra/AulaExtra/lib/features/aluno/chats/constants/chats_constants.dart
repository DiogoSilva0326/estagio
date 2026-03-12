import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Chats (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/chats/` para paddings, tipografia, estilos de cards,
///   cores de seleção e sombras.
class ChatsConstants {
  const ChatsConstants._();

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
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.394), blurRadius: 4.183),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 1.394),
      blurRadius: 2.789,
      spreadRadius: -1.394,
    ),
  ];
}
