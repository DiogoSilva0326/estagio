/// Medidas/layout da área de **Disponibilidade** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/disponibilidade/` (paddings da página e tabela)
/// - Dimensões da grelha de horários (células, cabeçalho, espaçamentos) e botão “Guardar”.
class DisponibilidadeProfessorLayout {
  const DisponibilidadeProfessorLayout._();

  static const double mobileHorizontalPadding = 16;
  static const double mobileTopPadding = 20;
  static const double mobileBottomPadding = 32;
  static const double mobileSectionGap = 18;
  static const double mobileCardRadius = 20;
  static const double mobileDayHeaderRadius = 16;
  static const double mobileSlotRadius = 12;
  static const double mobileDayCardPadding = 14;
  static const double mobileClearButtonHeight = 28;
  static const double mobileWeekNavHeight = 48;
  static const double mobileSaveButtonHeight = 40;
  static const double mobileActionRadius = 14;
  static const double mobileLegendDotSize = 14;

  /// Padding esquerdo do conteúdo (após menu lateral).
  static const double pageLeftPadding = 54;

  /// Padding direito do conteúdo.
  static const double pageRightPadding = 23.148;

  /// Distância do topo até ao início do conteúdo.
  static const double pageTopPadding = 46;

  /// Espaço entre sidebar (menu) e conteúdo.
  static const double sidebarContentGap = 28.889;

  /// Tamanho do título da página.
  static const double titleFontSize = 34;

  /// Altura de linha do título.
  static const double titleLineHeight = 43.333;

  /// Padding do bloco principal de conteúdo.
  static const double contentPadding = 28.889;

  /// Raio dos cartões.
  static const double cardRadius = 20;

  /// Padding interno dos cartões.
  static const double cardPadding = 28.889;

  /// Altura do botão “Guardar”.
  static const double saveButtonHeight = 48;

  /// Raio do botão “Guardar”.
  static const double saveButtonRadius = 16;

  /// Tamanho do ícone no botão “Guardar”.
  static const double saveButtonIconSize = 20;

  /// Tamanho do texto no botão “Guardar”.
  static const double saveButtonFontSize = 16;

  /// Altura de linha do texto no botão “Guardar”.
  static const double saveButtonLineHeight = 24;

  /// Dimensões vindas do Figma para a tabela de horários.
  static const double tableHeaderHeight = 42.92;

  /// Altura de cada linha (hora) da tabela.
  static const double tableRowHeight = 57.23;

  /// Tamanho base de cada célula da grelha (quadrado).
  static const double tableCellSize = 57.23;

  /// Largura da coluna das horas.
  static const double tableHourColumnWidth = 90;

  /// Raio de canto das células.
  static const double tableCellRadius = 9.54;

  /// Espessura da borda das células.
  static const double tableCellBorderWidth = 2.38;

  /// Espaço entre células.
  static const double tableCellGap = 9.54;

  /// Padding interno da célula/coluna da hora.
  static const double tableHourPadding = 9.54;

  /// Tamanho do quadrado da legenda (disponível / indisponível).
  static const double legendSquareSize = 28.61;
}
