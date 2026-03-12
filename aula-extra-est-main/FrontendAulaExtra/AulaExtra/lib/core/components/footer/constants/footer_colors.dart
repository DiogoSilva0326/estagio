import 'package:flutter/material.dart';

/// Cores usadas no **Footer** (rodapé) comum do site/app.
///
/// Onde é usado:
/// - Em `lib/core/components/footer/` (ex.: `FooterSection`, blocos e widgets do rodapé).
/// - Mantém o gradiente e cores de texto consistentes em todas as páginas.
class FooterColors {
  /// Cor inicial do gradiente do footer.
  static const gradientStart = Color(0xFFF15C64);

  /// Cor final do gradiente do footer.
  static const gradientEnd = Color(0xFFFC9039);

  /// Cor do texto do footer (títulos, links e descrições).
  static const textColor = Color(0xFF1E1E1E);
}
