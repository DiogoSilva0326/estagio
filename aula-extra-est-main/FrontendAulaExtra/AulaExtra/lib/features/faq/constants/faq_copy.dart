import 'package:flutter/material.dart';

/// Textos e conteúdo “fixo” da feature de **FAQ**.
///
/// Onde é usado:
/// - Em `lib/features/faq/` para popular o hero (título/subtítulo), placeholders,
///   CTAs e os grupos/perguntas apresentadas na página.
///
/// Boas práticas:
/// - Mantém aqui apenas copy/dados estáticos (sem lógica de UI).
class FaqCopy {
  /// Título do hero da página de FAQ.
  static const String heroTitle = 'Perguntas Frequentes';

  /// Subtítulo/descrição do hero.
  static const String heroSubtitle =
      'Encontra respostas rápidas às dúvidas mais comuns sobre a Aula Extra.';

  /// Placeholder da barra de pesquisa.
  static const String searchPlaceholder = 'Procura uma pergunta…';

  /// Label do botão de pesquisa.
  static const String searchButtonLabel = 'Procurar';

  static const String contactTitle = 'Ainda tens dúvidas?';
  static const String contactBody =
      'A nossa equipa está pronta para te ajudar! Entra em contacto connosco e responderemos o mais rápido possível.';
  static const String contactPrimaryCta = 'Contacta-nos';
  static const String contactSecondaryCta = 'Ver Tutoriais';
}

/// Dados de uma categoria (pills/filtros) da FAQ.
class FaqCategoryData {
  const FaqCategoryData({
    required this.id,
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String id;
  final String label;
  final IconData icon;
  final bool selected;
}

/// Dados de um grupo/seção de FAQ (ex.: Para Alunos, Pagamentos, etc.).
class FaqGroupData {
  const FaqGroupData({
    required this.accentColor,
    required this.title,
    required this.questionCountText,
    required this.questions,
    required this.initiallyExpanded,
  });

  final Color accentColor;
  final String title;
  final String questionCountText;
  final List<FaqQuestionData> questions;
  final bool initiallyExpanded;
}

/// Dados de uma pergunta individual da FAQ.
class FaqQuestionData {
  const FaqQuestionData({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
