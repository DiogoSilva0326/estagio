import 'package:flutter/material.dart';

/// Paleta de cores da área de **Disponibilidade** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/disponibilidade/` (ecrãs e widgets da grelha/tabela)
/// - Cartões, tabela de horários e botão de guardar disponibilidade.
class DisponibilidadeProfessorColors {
  const DisponibilidadeProfessorColors._();

  /// Cor base do fundo da página.
  static const Color background = Color(0xFFF9F9F9);

  /// Cor do título principal.
  static const Color title = Color(0xFF1E2939);

  /// Cor do texto normal.
  static const Color text = Color(0xFF364153);

  /// Cor de texto secundário/descritivo.
  static const Color muted = Color(0xFF6A7282);

  /// Borda base dos cartões/containers.
  static const Color cardBorder = Color(0xFFE5E7EB);

  /// Fundo do cabeçalho da tabela (dias/colunas).
  static const Color tableHeaderBackground = Color(0xFFF3F4F6);

  /// Borda das células da tabela.
  static const Color cellBorder = Color(0xFFE5E7EB);

  /// Destaque de célula marcada como disponível.
  static const Color availableBorder = Color(0xFFFF8C0B);

  /// Borda de célula não disponível/estado normal.
  static const Color unavailableBorder = Color(0xFFE5E7EB);

  /// Gradiente (topo) do botão “Guardar”.
  static const Color saveGradientTop = Color(0xFFFF8C0B);

  /// Gradiente (base) do botão “Guardar”.
  static const Color saveGradientBottom = Color(0xFFFF7426);
}
