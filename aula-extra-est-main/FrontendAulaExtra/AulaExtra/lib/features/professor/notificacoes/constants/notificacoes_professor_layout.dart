/// Medidas/layout da área de **Notificações** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/notificacoes/` (topo com título/subtítulo, botão “Marcar tudo”)
/// - Cards de notificação (padding, ícone, tipografia, ações e indicadores).
class NotificacoesProfessorLayout {
  const NotificacoesProfessorLayout._();

  /// Padding esquerdo do conteúdo (após menu lateral).
  static const double pageLeftPadding = 54;

  /// Padding direito do conteúdo.
  static const double pageRightPadding = 23.148;

  /// Distância do topo até ao início do conteúdo.
  static const double pageTopPadding = 90;

  /// Padding inferior da página.
  static const double pageBottomPadding = 90;

  /// Padding do bloco principal de conteúdo.
  static const double contentPadding = 28.737;

  /// Tamanho do título.
  static const double titleFontSize = 35.922;

  /// Altura de linha do título.
  static const double titleLineHeight = 43.106;

  /// Tamanho do subtítulo.
  static const double subtitleFontSize = 16.763;

  /// Altura de linha do subtítulo.
  static const double subtitleLineHeight = 23.948;

  /// Altura do botão “Marcar tudo como lido”.
  static const double markAllButtonHeight = 43.106;

  /// Raio do botão “Marcar tudo como lido”.
  static const double markAllButtonRadius = 14.369;

  /// Espessura da borda do botão.
  static const double markAllButtonBorderWidth = 1.197;

  /// Espaço entre cards.
  static const double cardsGap = 14.369;

  /// Altura de cada card.
  static const double cardHeight = 140.094;

  /// Raio do card.
  static const double cardRadius = 19.158;

  /// Espessura da borda do card.
  static const double cardBorderWidth = 1.197;

  /// Espessura da barra esquerda quando não lida.
  static const double cardUnreadLeftBorderWidth = 4.79;

  /// Padding esquerdo do card.
  static const double cardPaddingLeft = 28.737;

  /// Padding direito do card.
  static const double cardPaddingRight = 25.145;

  /// Padding superior do card.
  static const double cardPaddingTop = 25.145;

  /// Diâmetro do círculo do ícone.
  static const double iconCircleSize = 57.475;

  /// Tamanho do ícone.
  static const double iconSize = 28.737;

  /// Espaçamento vertical interno entre linhas do card.
  static const double rowGap = 19.158;

  /// Tipografia do heading/título da notificação.
  static const double headingFontSize = 21.553;
  static const double headingLineHeight = 32.329;

  /// Tipografia do corpo/descrição.
  static const double bodyFontSize = 16.763;
  static const double bodyLineHeight = 23.948;

  /// Tipografia do texto de hora.
  static const double timeFontSize = 14.369;
  static const double timeLineHeight = 19.158;

  /// Botões de ação (ex.: apagar/fechar).
  static const double actionButtonSize = 43.106;
  static const double actionIconSize = 19.158;
  static const double actionButtonRadius = 9.579;

  /// Tamanho do “dot” indicador de não lida.
  static const double unreadDotSize = 9.579;

  /// Blur das sombras do card.
  static const double shadowBlur1 = 7.184;
  static const double shadowBlur2 = 4.79;
}
