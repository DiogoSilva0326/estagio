import 'package:flutter/material.dart';

/// Design tokens (cores/gradientes/dimensões) usados na feature de **FAQ**.
///
/// Onde é usado:
/// - Em `lib/features/faq/` (página de FAQ, cards de perguntas, filtros, headers).
/// - Mantém tipografia, cores e formas consistentes dentro do FAQ.
class FaqColors {
  /// Texto principal (títulos e perguntas).
  static const Color textPrimary = Color(0xFF101828);

  /// Texto secundário (subtítulos e descrições).
  static const Color textSecondary = Color(0xFF4A5565);

  /// Texto menos destacado (metadados, contagens, hints).
  static const Color textMuted = Color(0xFF6A7282);

  /// Texto em botões secundários/links no FAQ.
  static const Color textButtonSecondary = Color(0xFF364153);

  /// Borda muito suave (separadores discretos).
  static const Color borderLight = Color(0xFFF3F4F6);

  /// Borda padrão (cards, outlines).
  static const Color borderDefault = Color(0xFFE5E7EB);

  /// Laranja principal (accent da página, ícones/cta).
  static const Color orange = Color(0xFFFF6B00);

  /// Variante clara do laranja (gradientes/realces).
  static const Color orangeLight = Color(0xFFFF9966);

  /// Fundo laranja suave (pills, badges e fundos claros).
  static const Color orangeSoft = Color(0xFFFFEDD4);

  /// Cor intermédia usada no fundo do hero.
  static const Color heroMid = Color(0xFFFFF7ED);

  /// Fundo do índice (número) de cada pergunta.
  static const Color questionIndexBg = Color(0xFFFFEDD4);

  /// Cor do texto do índice (número) de cada pergunta.
  static const Color questionIndexText = Color(0xFFFF6B00);
}

/// Gradientes reutilizados na UI de FAQ.
class FaqGradients {
  /// Gradiente vertical laranja (accent).
  static const LinearGradient orangeVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [FaqColors.orange, FaqColors.orangeLight],
  );

  /// Fundo do hero (branco ↔ tons suaves ↔ branco).
  static const LinearGradient heroBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, FaqColors.heroMid, Colors.white],
    stops: [0, 0.5, 1],
  );

  /// Fundo de cabeçalhos de secção dentro do FAQ.
  static const LinearGradient sectionHeader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF9FAFB), Colors.white],
  );

  /// Fundo da secção de contacto (call-to-action) no fim do FAQ.
  static const LinearGradient contactBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FaqColors.heroMid, Colors.white, FaqColors.heroMid],
    stops: [0, 0.5, 1],
  );
}

/// Dimensões (bordas/radii) padronizadas na feature de FAQ.
class FaqDimens {
  /// Espessura de borda fina.
  static const double borderThin = 1.276;

  /// Espessura de borda mais marcada.
  static const double borderThick = 2.552;

  /// Raio para pills (totalmente arredondado).
  static const double radiusPill = 9999;

  /// Raio de cards.
  static const double radiusCard = 20.417;

  /// Raio de botões.
  static const double radiusButton = 17.865;
}
