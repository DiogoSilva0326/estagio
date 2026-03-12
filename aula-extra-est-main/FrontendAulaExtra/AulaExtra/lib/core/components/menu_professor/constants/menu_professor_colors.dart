import 'package:flutter/material.dart';

/// Paleta de cores do **Menu do Professor** (navegação lateral/vertical do professor).
///
/// Onde é usado:
/// - Em `lib/core/components/menu_professor/` (widgets do menu, itens, seleção).
/// - Centraliza cores (texto, badges, estados) para consistência visual.
class MenuProfessorColors {
  const MenuProfessorColors._();

  /// Cor de fundo do menu.
  static const Color background = Colors.white;

  /// Cor do texto de títulos/cabeçalhos no menu.
  static const Color textHeading = Color(0xFF1E2939);

  /// Cor do texto normal dos itens de navegação.
  static const Color textNav = Color(0xFF364153);

  /// Cor do texto secundário/menos destacado.
  static const Color textMuted = Color(0xFF4A5565);

  /// Cor dos divisores/separadores.
  static const Color divider = Color(0xFFE5E7EB);

  /// Cor de realce (ações/ícones) em laranja.
  static const Color accentOrange = Color(0xFFFF6B00);

  /// Cor de realce (sucesso/estado ok) em verde.
  static const Color accentGreen = Color(0xFF00A63E);

  /// Cor de realce (links/ações) em azul.
  static const Color accentBlue = Color(0xFF155DFC);

  /// Cor do badge/indicador (ex.: notificações por ler).
  static const Color badgeRed = Color(0xFFFB2C36);

  /// Fundo do item selecionado (estado ativo do menu).
  static const Color navSelectedBackground = Color(0xFFFFF7ED);
}
