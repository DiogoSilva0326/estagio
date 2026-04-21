import 'package:flutter/material.dart';

/// Paleta de cores do ecrã **Meus Alunos** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/meus_alunos/` (cards de aluno, badges, progresso e chips de disciplinas)
/// - Mapeamento de cores por disciplina (em `meus_alunos_professor_mock_data.dart`).
class MeusAlunosProfessorColors {
  const MeusAlunosProfessorColors._();

  /// Cor base do fundo da página.
  static const Color pageBackground = Color(0xFFF9F9F9);

  /// Alias para manter compatibilidade com nomes usados nos widgets.
  static const Color background = pageBackground;

  /// Superfície branca base dos cartões mobile.
  static const Color mobileSurface = Colors.white;

  /// Cor de texto secundário em mobile.
  static const Color mobileMutedText = Color(0xFF667085);

  /// Cor da borda suave dos cartões mobile.
  static const Color mobileBorder = Color(0xFFE5E7EB);

  /// Fundo do cartão de estatísticas.
  static const Color mobileSoftSurface = Color(0xFFFFF7ED);

  /// Cor usada para ações de alerta.
  static const Color danger = Color(0xFFFB2C36);

  /// Cor usada no destaque de progresso.
  static const Color success = Color(0xFF00A63E);

  /// Sombra base usada nos cartões mobile.
  static const List<BoxShadow> mobileShadow = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.08),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  /// Cor do título principal.
  static const Color title = Color(0xFF1E2939);

  /// Borda dos cards.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Cor do nome do aluno.
  static const Color name = Color(0xFF1E2939);

  /// Cor de labels secundárias (ex.: “Última aula”).
  static const Color labelMuted = Color(0xFF6A7282);

  /// Alias para texto secundário.
  static const Color muted = labelMuted;

  /// Cor do valor principal (texto de conteúdo).
  static const Color value = Color(0xFF364153);

  /// Cor do rótulo do progresso.
  static const Color progressLabel = Color(0xFF4A5565);

  /// Cor do valor do progresso.
  static const Color progressValue = Color(0xFF1E2939);

  /// Cores base usadas em badges/chips.
  static const Color orange = Color(0xFFFF6B00);
  static const Color blue = Color(0xFF2B7FFF);
  static const Color green = Color(0xFF00C950);
  static const Color purple = Color(0xFFA74AD4);

  /// Variante de laranja usada em “badge” (ex.: disciplina).
  static const Color orangeBadge = Color(0xFFFF6900);
}
