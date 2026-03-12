import 'package:flutter/material.dart';

/// Design tokens do ecrã de **Notificações (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/notificacoes/` para paddings, tipografia, estilos
///   do resumo de não lidas, pills/ícones e cards de notificação.
class NotificacoesConstants {
  const NotificacoesConstants._();

  /// Padding horizontal geral.
  static const horizontalPadding = 40.85;

  /// Padding vertical geral.
  static const verticalPadding = 44.255;

  /// Estilo do título principal.
  static const titleStyle = TextStyle(
    fontSize: 42.162,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 50.595 / 42.162,
  );

  /// Estilo do subtítulo/descrição.
  static const subtitleStyle = TextStyle(
    fontSize: 22.486,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.73 / 22.486,
  );

  /// Estilo do link/ação (ex.: “Marcar como lidas”, “Ver tudo”, etc.).
  static const actionLinkStyle = TextStyle(
    fontSize: 19.676,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFF6B00),
    height: 28.108 / 19.676,
  );

  /// Cor da borda do resumo de notificações não lidas.
  static const unreadSummaryBorderColor = Color(0xFFFFD6A7);

  /// Gradiente do resumo de notificações não lidas.
  static const unreadSummaryGradient = LinearGradient(
    begin: Alignment(-0.86, -0.5),
    end: Alignment(0.86, 0.5),
    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD4)],
  );

  /// Laranja principal (accent).
  static const orange = Color(0xFFFF6B00);

  /// Variante suave do laranja (gradiente/realces).
  static const orangeSoft = Color(0xFFFF9966);

  /// Gradiente usado nos ícones/pills laranja.
  static const iconOrangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orange, orangeSoft],
  );

  /// Sombra de pills (chips/resumos).
  static const pillShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8.432, offset: Offset(0, 5.622)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 5.622, offset: Offset(0, 2.811)),
  ];

  /// Sombra dos cards de notificação.
  static const cardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4.216, offset: Offset(0, 1.405)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 2.811, offset: Offset(0, 1.405)),
  ];

  /// Raio dos cards.
  static const cardRadius = 22.486;

  /// Espessura de borda.
  static const borderWidth = 1.405;
}
