import 'package:flutter/material.dart';

/// Constantes (layout + cores) do fluxo **Tornar-se Explicador**.
///
/// Objetivo:
/// - Evitar valores “hardcoded” espalhados pelos widgets.
/// - Facilitar manutenção do layout (métricas e cores locais) sem mexer na lógica.
///
/// Onde é usado:
/// - `lib/features/become_teacher/pages/become_teacher_screen.dart`
/// - `lib/features/become_teacher/widgets/become_teacher_card.dart`
class BecomeTeacherLayout {
  const BecomeTeacherLayout._();

  /// Espaço superior antes do conteúdo principal.
  static const double topSpacerHeight = 54;

  /// Largura máxima do conteúdo (para não esticar em ecrãs grandes).
  static const double maxContentWidth = 1404;

  /// Largura de design do bloco principal (card + hero).
  static const double contentWidth = 1404;

  /// Espaço “vazio” à esquerda para alinhar com o layout (menu/coluna).
  static const double leftSpacerWidth = 233;

  /// Espaço entre o card e o painel/hero da direita.
  static const double cardHeroGap = 52;

  /// Espaço entre o conteúdo e o footer.
  static const double beforeFooterGap = 16;

  /// Largura do card.
  static const double cardWidth = 428;

  /// Raio do card.
  static const double cardRadius = 20.063;

  /// Blur da sombra do card.
  static const double cardShadowBlur = 41.797;

  /// Spread da sombra do card.
  static const double cardShadowSpread = -10.031;

  /// Offset vertical da sombra do card.
  static const double cardShadowOffsetY = 20.898;

  /// Altura da barra de tabs no topo do card.
  static const double tabsHeight = 50.992;

  /// Espessura da linha inferior das tabs.
  static const double tabsBottomBorderWidth = 0.836;

  /// Raio das tabs no topo (cantos).
  static const double tabsCornerRadius = 20;

  /// Tipografia do texto das tabs.
  static const double tabFontSize = 15.047;

  /// Altura de linha do texto das tabs.
  static const double tabLineHeight = 23.406;

  /// Espaçamento das tabs (letter spacing do design).
  static const double tabLetterSpacing = -0.3674;

  /// Padding interno do conteúdo do card.
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(26.75, 26.75, 26.75, 22);

  /// Título principal do formulário.
  static const double formTitleFontSize = 25.078;

  /// Altura de linha do título.
  static const double formTitleLineHeight = 30.094;

  /// Espaçamento do título.
  static const double formTitleLetterSpacing = 0.3306;

  /// Espaço entre título e subtítulo.
  static const double titleSubtitleGap = 6.688;

  /// Tipografia do subtítulo.
  static const double subtitleFontSize = 13.375;

  /// Altura de linha do subtítulo.
  static const double subtitleLineHeight = 20.063;

  /// Letter spacing do subtítulo.
  static const double subtitleLetterSpacing = -0.2612;

  /// Padding superior do título de secção.
  static const EdgeInsets sectionTitlePadding = EdgeInsets.only(top: 18);

  /// Tipografia do título de secção.
  static const double sectionTitleFontSize = 13.375;

  /// Espaço vertical padrão entre campos.
  static const double fieldGap = 12;

  /// Tipografia do label do campo.
  static const double fieldLabelFontSize = 11.703;

  /// Altura de linha do label do campo.
  static const double fieldLabelLineHeight = 16.719;

  /// Letter spacing do label do campo.
  static const double fieldLabelLetterSpacing = -0.1257;

  /// Espaço entre label e input.
  static const double labelFieldGap = 6.688;

  /// Altura do input (quando é single-line).
  static const double inputHeight = 43.469;

  /// Raio do input.
  static const double inputRadius = 11.703;

  /// Espessura da borda do input.
  static const double inputBorderWidth = 1.672;

  /// Padding interno do input.
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(horizontal: 13.375, vertical: 10.031);

  /// Padding do prefix icon dentro do input.
  static const EdgeInsetsGeometry prefixPadding = EdgeInsetsDirectional.only(start: 13.375, end: 10);

  /// Constraints do prefix icon.
  static const BoxConstraints prefixConstraints = BoxConstraints.tightFor(width: 40.125, height: 43.469);

  /// Tamanho dos ícones dentro dos inputs.
  static const double inputIconSize = 16.719;

  /// Constraints do ícone “mostrar/esconder” password.
  static const BoxConstraints passwordSuffixConstraints = BoxConstraints.tightFor(width: 32, height: 32);

  /// Espaçamento entre colunas (certificado nome + remover).
  static const double certificateNameRemoveGap = 8;

  /// Espaçamento entre nome e link do certificado.
  static const double certificateNameLinkGap = 8;

  /// Espaço antes do botão de submit.
  static const double beforeSubmitGap = 18;

  /// Altura do botão de submit.
  static const double submitHeight = 50.156;

  /// Raio do botão de submit.
  static const double submitRadius = 11.703;

  /// Tipografia do texto do botão.
  static const double submitFontSize = 15.047;

  /// Altura de linha do texto do botão.
  static const double submitLineHeight = 23.406;

  /// Letter spacing do botão.
  static const double submitLetterSpacing = -0.3674;
}

/// Cores locais do fluxo **Tornar-se Explicador**.
///
/// Nota:
/// - As cores globais do design (ex.: gradientes e texto) continuam em `RegisterColors`.
/// - Este ficheiro guarda apenas as cores “soltas” que estavam hardcoded nos widgets.
class BecomeTeacherColors {
  const BecomeTeacherColors._();

  /// Fundo da página.
  static const Color pageBackground = Colors.white;

  /// Fundo da tab inativa.
  static const Color inactiveTabBackground = Color(0xFFF9FAFB);

  /// Cor da linha inferior/divisor nas tabs.
  static const Color tabsDivider = Color(0xFFE5E7EB);

  /// Cor dos labels dos campos.
  static const Color fieldLabel = Color(0xFF364153);

  /// Cor do hint (50% opacidade).
  static const Color hintText = Color.fromRGBO(10, 10, 10, 0.5);

  /// Cor do ícone/placeholder dentro dos inputs.
  static const Color inputIconMuted = Color(0xFF99A1AF);

  /// Cor do ícone de remover certificado.
  static const Color removeIcon = Color(0xFF6A7282);

  /// Cor do botão de submit quando desativado.
  static const Color submitDisabledBackground = Color(0xFFD1D5DC);

  /// Cor do texto do botão de submit quando desativado.
  static const Color submitDisabledText = Color(0xFF6A7282);
}
