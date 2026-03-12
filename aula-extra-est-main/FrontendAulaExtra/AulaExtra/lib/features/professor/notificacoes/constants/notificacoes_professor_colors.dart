import 'package:flutter/material.dart';

/// Paleta de cores da área de **Notificações** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/notificacoes/` (cards de notificação, estados lida/não lida, ícones)
/// - Botão “Marcar tudo como lido” e indicadores de não lido.
class NotificacoesProfessorColors {
  const NotificacoesProfessorColors._();

  /// Cor base do fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título principal.
  static const Color title = Color(0xFF1E2939);

  /// Cor do subtítulo/descrição no topo.
  static const Color subtitle = Color(0xFF4A5565);

  /// Cor do texto de hora/data.
  static const Color timeText = Color(0xFF6A7282);

  /// Borda do botão “Marcar tudo”.
  static const Color buttonBorder = Color(0x1A000000);

  /// Texto do botão “Marcar tudo”.
  static const Color buttonText = Color(0xFF0A0A0A);

  /// Borda do card quando está não lido.
  static const Color unreadBorder = Color(0x1A000000);

  /// Cor do destaque/acento para estado “não lido”.
  static const Color unreadAccent = Color(0xFFFF6B00);

  /// Borda do card quando está lido.
  static const Color readBorder = Color(0xFFE5E7EB);

  /// Fundos do círculo do ícone (por tipo de notificação).
  static const Color iconBlueBg = Color(0xFFDBEAFE);
  static const Color iconGreenBg = Color(0xFFDCFCE7);
  static const Color iconPurpleBg = Color(0xFFF3E8FF);
  static const Color iconYellowBg = Color(0xFFFEF9C2);
}
