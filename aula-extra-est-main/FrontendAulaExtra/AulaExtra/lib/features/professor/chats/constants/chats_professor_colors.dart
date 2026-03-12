import 'package:flutter/material.dart';

/// Paleta de cores do ecrã de **Chats (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/chats/` para fundo, lista de conversas, bubbles,
///   input de mensagem, badges e gradientes.
class ChatsProfessorColors {
  const ChatsProfessorColors._();

  /// Fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título.
  static const Color title = Color(0xFF1E2939);

  /// Texto “muted” (subtítulos/estado).
  static const Color mutedText = Color(0xFF6A7282);

  /// Fundo dos cards.
  static const Color cardBackground = Colors.white;

  /// Borda dos cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Fundo da barra de pesquisa.
  static const Color searchBackground = Color(0xFFF3F3F5);

  /// Fundo da conversa selecionada na lista.
  static const Color chatListSelectedBackground = Color(0xFFFFF7ED);

  /// Cor do divisor entre itens.
  static const Color divider = Color(0xFFF3F4F6);

  /// Fundo do badge de não lidas.
  static const Color unreadBadgeBackground = Color(0xFFFB2C36);

  /// Fundo da bubble (mensagem recebida).
  static const Color leftBubbleBackground = Color(0xFFF3F4F6);

  /// Texto da bubble (mensagem recebida).
  static const Color leftBubbleText = Color(0xFF1E2939);

  /// Fundo do input de escrever mensagem.
  static const Color inputBackground = Color(0xFFF3F3F5);

  /// Gradiente do avatar (iniciais).
  static const Color avatarGradientStart = Color(0xFF51A2FF);
  static const Color avatarGradientEnd = Color(0xFF155DFC);

  /// Gradiente da bubble (mensagem enviada).
  static const Color rightBubbleGradientStart = Color(0xFFFF6B00);
  static const Color rightBubbleGradientEnd = Color(0xFFFF9966);
}
