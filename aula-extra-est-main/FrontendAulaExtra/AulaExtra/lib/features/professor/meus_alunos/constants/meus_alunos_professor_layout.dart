/// Medidas/layout do ecrã **Meus Alunos** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/meus_alunos/` (grid de cards de aluno, avatar, header, badges e ações)
/// - Valores alinhados com o Figma para garantir consistência visual.
class MeusAlunosProfessorLayout {
  const MeusAlunosProfessorLayout._();

  /// Largura do design (Figma) usada como referência.
  static const double designWidth = 1440.0;

  /// Padding esquerdo do conteúdo (após menu lateral).
  static const double pageLeftPadding = 46.0;

  /// Padding direito do conteúdo.
  static const double pageRightPadding = 43.06;

  /// Distância do topo até ao início do conteúdo.
  static const double pageTopPadding = 46.0;

  /// Espaço entre sidebar (menu) e conteúdo.
  static const double sidebarContentGap = 21.395;

  /// Tamanho do título.
  static const double titleFontSize = 36.932;

  /// Altura de linha do título.
  static const double titleLineHeight = 44.318;

  /// Espaço abaixo do título.
  static const double titleBottomGap = 31.823;

  /// Espaçamento entre cards na grid.
  static const double gridSpacing = 29.547;

  /// Largura fixa do card.
  static const double cardWidth = 320.893;

  /// Card (Figma)
  static const double cardHeight = 337.31;
  static const double cardPaddingTop = 30.78;
  static const double cardPaddingSides = 30.78;
  static const double cardPaddingBottom = 1.23;
  static const double cardBorderWidth = 1.23;
  static const double cardRadius = 19.70;

  /// Avatar (Figma)
  static const double avatarSize = 78.79;

  /// Card header (derivado de medições do Figma)
  static const double headerTextBlockHeight = 68.94;
  static const double headerNameFontSize = 22.16;
  static const double headerNameLineHeight = 1.56;
  static const double headerBadgesTopGap = 9.85;
  static const double headerBadgeRowHeight = 24.52;

  /// Bloco “Última aula” (Figma)
  static const double lastLessonBlockHeight = 53.24;
  static const double lastLessonFontSize = 17.23;
  static const double lastLessonLineHeight = 1.43;

  /// Linha de ações (Figma)
  static const double actionsRowHeight = 44.32;
  static const double actionButtonSize = 44.32;
  static const double actionButtonRadius = 12.31;
  static const double actionIconSize = 19.70;
  static const double actionBorderWidth = 1.23;
}
