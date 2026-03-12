/// Dimensões do layout do ecrã de **Calendário (Professor)**.
///
/// Onde é usado:
/// - Em `lib/features/professor/calendario/` para tamanhos/espacamentos do layout
///   (padding de página, tabs, cards e botões) de acordo com o design (Figma).
class CalendarioProfessorLayout {
  const CalendarioProfessorLayout._();

  /// Largura base do design (desktop/web).
  static const double designWidth = 1440.0;

  /// Paddings externos da página (mantém consistente com outras páginas de professor).
  static const double pageLeftPadding = 46.0;
  static const double pageRightPadding = 43.06;
  static const double pageTopPadding = 46.0;
  static const double sidebarContentGap = 21.395;

  /// Padding do content interno (Figma).
  static const double contentPadding = 28.36;

  /// Gap entre blocos do content (Figma).
  static const double contentGap = 28.36;

  /// Tipografia do título (Figma).
  static const double titleFontSize = 35.45;
  static const double titleLineHeight = 42.54;

  static const double addButtonWidth = 196.055;
  static const double addButtonHeight = 42.54;
  static const double addButtonRadius = 14.18;
  static const double addButtonIconSize = 18.907;
  static const double addButtonFontSize = 16.543;
  static const double addButtonLineHeight = 23.633;

  /// Tabs (Figma).
  static const double tabsWidth = 316.022;
  static const double tabsHeight = 42.54;
  static const double tabsRadius = 14.18;

  static const double tabHeight = 31.905;
  static const double tabRadius = 11.817;
  static const double tabFontSize = 16.543;
  static const double tabLineHeight = 23.633;
  static const double tabPaddingH = 10.635;
  static const double tabPaddingV = 5.909;

  /// Lista de cards (Figma).
  static const double listGap = 18.907;
  static const double aulaCardHeight = 111.077;
  static const double aulaCardRadius = 18.907;
  static const double aulaCardBorderWidth = 1.182;
  static const double aulaCardPaddingTop = 24.815;
  static const double aulaCardPaddingSides = 24.815;
  static const double aulaCardPaddingBottom = 1.182;

  /// Conteúdo da linha do card de aula (Figma).
  static const double aulaRowHeight = 61.447;
  static const double avatarSize = 56.72;
  static const double avatarFontSize = 16.543;
  static const double avatarLineHeight = 23.633;

  static const double nameFontSize = 21.27;
  static const double nameLineHeightPx = 33.087;
  static const double badgeHeight = 23.633;
  static const double badgeRadius = 16.543;
  static const double badgeFontSize = 14.18;
  static const double badgeLineHeightPx = 18.907;
  static const double badgePaddingH = 9.453;
  static const double badgePaddingV = 2.363;

  static const double metaFontSize = 16.543;
  static const double metaLineHeight = 23.633;
  static const double metaGap = 14.18;

  /// Botões de ação (Figma).
  static const double actionsHeight = 42.54;
  static const double actionRadius = 11.817;
  static const double actionGap = 9.453;
  static const double actionIconSize = 18.907;
  static const double cancelButtonWidth = 133.962;
  static const double cancelBorderWidth = 1.182;
}
