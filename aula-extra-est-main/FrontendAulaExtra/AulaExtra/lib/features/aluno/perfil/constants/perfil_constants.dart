import 'package:flutter/material.dart';

/// Constantes de UI (tamanhos, estilos e cores) usadas no **Perfil do Aluno**.
///
/// Onde é usado:
/// - Em widgets e secções dentro de `lib/features/aluno/perfil/`.
/// - Serve como “design tokens” do ecrã para manter paddings/cores/estilos consistentes.
class PerfilConstants {
  const PerfilConstants._();

  static const backgroundColor = Color(0xFFF9F9F9);
  static const mobileHorizontalPadding = 19.0;
  static const mobileVerticalPadding = 16.0;
  static const mobileSectionSpacing = 18.0;
  static const mobileCardRadius = 20.0;
  static const mobileFieldRadius = 14.0;
  static const mobileBorderColor = Color(0xFFE5E7EB);
  static const mobileCardBorderColor = Color(0xFFE9EAEB);
  static const mobileSoftFill = Color(0xFFF3F4F6);
  static const mobileMutedColor = Color(0xFF667085);
  static const mobileTextColor = Color(0xFF101828);
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

  static const mobileSectionHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: mobileTextColor,
    height: 24 / 18,
  );

  static const mobileLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF364153),
    height: 20 / 14,
  );

  static const mobileFieldTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF0A0A0A),
    height: 24 / 16,
  );

  static const mobileHintStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0x800A0A0A),
    height: 24 / 16,
  );

  static const mobileButtonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 24 / 16,
  );

  static const mobileBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 20 / 14,
  );

  static const mobileSmallGap = 8.0;
  static const mobileFieldGap = 16.0;
  static const mobileCardGap = 18.0;
  static const mobilePillHeight = 40.0;
  static const mobileInterestChipHeight = 34.0;

  /// Padding horizontal padrão do conteúdo do ecrã de perfil.
  static const horizontalPadding = 40.85;

  /// Padding vertical padrão do conteúdo do ecrã de perfil.
  static const verticalPadding = 44.255;

  /// Estilo do título principal (ex.: heading no topo do perfil).
  static const titleStyle = TextStyle(
    fontSize: 41.713,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 50.056 / 41.713,
  );

  /// Estilo do subtítulo/descrição logo abaixo do título.
  static const subtitleStyle = TextStyle(
    fontSize: 22.247,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5565),
    height: 33.371 / 22.247,
  );

  /// Raio (arredondamento) de cards principais do perfil.
  static const cardRadius = 22.247;

  /// Raio (arredondamento) de campos/inputs do perfil.
  static const fieldRadius = 19.466;

  /// Cor da borda dos cards do perfil.
  static const cardBorderColor = Color(0xFFF3F4F6);

  /// Cor da borda dos campos/inputs do perfil.
  static const fieldBorderColor = Color(0xFFE5E7EB);

  /// Cor de preenchimento “suave” (background) usada em áreas secundárias.
  static const softFill = Color(0xFFF3F4F6);

  /// Laranja principal usado em botões/destaques do perfil.
  static const orange = Color(0xFFFF6B00);

  /// Laranja secundário (mais claro) para gradientes/destaques suaves.
  static const orangeSoft = Color(0xFFFF9966);

  /// Estilo dos labels (ex.: nome do campo acima do input).
  static const labelStyle = TextStyle(
    fontSize: 19.466,
    fontWeight: FontWeight.w500,
    color: Color(0xFF364153),
    height: 27.809 / 19.466,
  );

  /// Estilo do texto preenchido dentro dos campos (valor do input).
  static const fieldTextStyle = TextStyle(
    fontSize: 22.247,
    fontWeight: FontWeight.w400,
    color: Color(0xFF0A0A0A),
    height: 33.371 / 22.247,
  );

  /// Estilo do título de secções dentro do perfil (ex.: “Dados pessoais”, “Preferências”).
  static const sectionHeadingStyle = TextStyle(
    fontSize: 25.028,
    fontWeight: FontWeight.w500,
    color: Color(0xFF101828),
    height: 38.933 / 25.028,
  );

  /// Estilo do texto de botões principais (ex.: “Guardar alterações”).
  static const buttonTextStyle = TextStyle(
    fontSize: 22.247,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 33.371 / 22.247,
  );

  /// Estilo para hints/placeholder com menor contraste.
  static const mutedHintStyle = TextStyle(
    fontSize: 22.247,
    fontWeight: FontWeight.w400,
    color: Color(0x800A0A0A),
  );

  /// Sombra padrão de cards do perfil (elevação leve).
  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4.171,
      offset: Offset(0, 1.39),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 2.781,
      offset: Offset(0, 1.39),
    ),
  ];

  /// Sombra “flutuante” para elementos com mais destaque (elevação maior).
  static const floatingShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20.857,
      offset: Offset(0, 13.904),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.343,
      offset: Offset(0, 5.562),
    ),
  ];

  /// Padding vertical interno padrão dentro de cards do perfil.
  static const verticalCardPadding = 45.885;

  /// Padding horizontal interno padrão dentro de cards do perfil.
  static const horizontalCardPadding = 45.885;

  /// Espaçamento vertical entre cards/secções.
  static const cardGap = 44.494;

  /// Espaçamento vertical entre campos (inputs).
  static const fieldGap = 33.371;

  /// Espaçamento pequeno usado entre elementos compactos.
  static const smallGap = 11.124;

  /// Altura padrão de “pills”/chips no perfil.
  static const pillHeight = 55.618;

  /// Altura de chips de interesses/áreas.
  static const interestChipHeight = 50.056;

  /// Gradiente laranja padrão (ex.: em botões principais e destaques).
  static const gradientOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orange, orangeSoft],
  );
}
