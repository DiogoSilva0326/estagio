import 'package:flutter/material.dart';

/// Design tokens do fluxo **Marcar Aula com Professor**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/marcar_aula_professor/` para cores, gradientes,
///   paddings e estilos (top bar, secções, links) do ecrã de marcação.
class MarcarAulaProfessorConstants {
  /// Padding horizontal geral.
  static const double horizontalPadding = 40;

  /// Padding vertical geral.
  static const double verticalPadding = 40;

  /// Fundo da página.
  static const Color pageBackground = Color(0xFFF9F9F9);

  /// Superfície neutra (cards/blocos).
  static const Color surfaceMuted = Color(0xFFF9FAFB);

  /// Texto principal.
  static const Color textDark = Color(0xFF101828);

  /// Texto secundário.
  static const Color textMuted = Color(0xFF6A7282);

  /// Texto ainda mais subtil (placeholders/metadados).
  static const Color textSubtle = Color(0xFF99A1AF);

  /// Borda padrão.
  static const Color border = Color(0xFFE5E7EB);

  /// Borda suave.
  static const Color borderSoft = Color(0xFFF3F4F6);

  /// Borda específica para seleção do tipo de aula.
  static const Color lessonTypeBorder = Color(0xFFD1D5DC);

  /// Laranja principal (accent).
  static const Color orange = Color(0xFFFF6B00);

  /// Variante suave do laranja.
  static const Color orangeSoft = Color(0xFFFF9966);

  /// Gradiente laranja para botões/realces.
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orange, orangeSoft],
  );

  /// Verde (sucesso/estado disponível).
  static const Color green = Color(0xFF008236);

  /// Fundo verde suave.
  static const Color greenSoft = Color(0xFFDCFCE7);

  /// Azul (informação/ações secundárias).
  static const Color blue = Color(0xFF2B7FFF);

  /// Estilo do título na top bar.
  static const TextStyle topBarTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  /// Estilo do nome do explicador na top bar.
  static const TextStyle topBarTutorNameStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: orange,
  );

  /// Estilo do título de secção.
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  /// Estilo de links/ações.
  static const TextStyle linkStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: orange,
  );
}
