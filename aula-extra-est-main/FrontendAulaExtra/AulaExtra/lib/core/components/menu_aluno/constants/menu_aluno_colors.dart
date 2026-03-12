import 'package:flutter/material.dart';

/// Paleta de cores do **Menu do Aluno** (navegação lateral/vertical do aluno).
///
/// Onde é usado:
/// - Em `lib/core/components/menu_aluno/` (ex.: widgets que renderizam o menu e
///   os seus itens/estado selecionado).
/// - Centraliza as cores para manter consistência visual entre ecrãs.
class MenuAlunoColors {
  const MenuAlunoColors._();

  /// Cor de fundo do menu.
  static const Color background = Colors.white;

  /// Cor do texto de títulos/cabeçalhos no menu.
  static const Color textHeading = Color(0xFF101828);

  /// Cor do texto normal dos itens de navegação.
  static const Color textNav = Color(0xFF364153);

  /// Cor do texto secundário/menos destacado.
  static const Color textMuted = Color(0xFF4A5565);

  /// Cor dos divisores/separadores entre secções/itens.
  static const Color divider = Color(0xFFE5E7EB);

  /// Cor de realce (ações/ícones) em laranja.
  static const Color accentOrange = Color(0xFFFF6B00);

  /// Cor de realce (sucesso/estado ok) em verde.
  static const Color accentGreen = Color(0xFF00A63E);

  /// Cor do badge/indicador (ex.: notificações por ler).
  static const Color badgeRed = Color(0xFFFB2C36);
}
