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

  static const List<FaqCategoryData> categories = [
    FaqCategoryData(
      label: 'Para Alunos',
      icon: Icons.school_outlined,
      width: 167.744,
      selected: true,
    ),
    FaqCategoryData(
      label: 'Para Explicadores',
      icon: Icons.person_outline,
      width: 218.578,
      selected: false,
    ),
    FaqCategoryData(
      label: 'Pagamentos e Preços',
      icon: Icons.payments_outlined,
      width: 249.722,
      selected: false,
    ),
    FaqCategoryData(
      label: 'Aulas e Tecnologia',
      icon: Icons.videocam_outlined,
      width: 223.224,
      selected: false,
    ),
    FaqCategoryData(
      label: 'Conta e Segurança',
      icon: Icons.lock_outline,
      width: 206.146,
      selected: false,
    ),
  ];

  static const String contactTitle = 'Ainda tens dúvidas?';
  static const String contactBody =
      'A nossa equipa está pronta para te ajudar! Entra em contacto connosco e responderemos o mais rápido possível.';
  static const String contactPrimaryCta = 'Contacta-nos';
  static const String contactSecondaryCta = 'Ver Tutoriais';

  static const List<FaqGroupData> groups = [
    FaqGroupData(
      accentColor: Color(0xFF2B7FFF),
      title: 'Para Alunos',
      questionCountText: '6 perguntas',
      questions: [
        FaqQuestionData(
          question: 'Como marco uma aula?',
          answer:
              'Vai à área de marcação, escolhe a disciplina e o explicador, seleciona um horário disponível e confirma a marcação.',
        ),
        FaqQuestionData(
          question: 'Quanto custa uma aula?',
          answer:
              'O preço varia consoante o explicador e a duração da aula. Vês sempre o valor final antes de confirmares.',
        ),
        FaqQuestionData(
          question: 'Posso cancelar ou reagendar uma aula?',
          answer:
              'Sim. Nas tuas aulas marcadas podes cancelar ou reagendar, desde que respeites a antecedência definida pelo explicador.',
        ),
        FaqQuestionData(
          question: 'O que acontece se o explicador não aparecer?',
          answer:
              'Podes reportar a situação na aula marcada. A equipa analisa o caso e ajuda-te a reagendar ou resolver o pagamento conforme aplicável.',
        ),
        FaqQuestionData(
          question: 'Posso ter uma aula experimental antes de me comprometer?',
          answer:
              'Depende do explicador. Alguns oferecem uma primeira sessão curta/experimental; verifica essa informação no perfil do explicador.',
        ),
        FaqQuestionData(
          question: 'Como funciona o sistema de avaliações?',
          answer:
              'Depois da aula podes avaliar o explicador e deixar feedback. As avaliações ajudam outros alunos a escolherem com confiança.',
        ),
      ],
      initiallyExpanded: true,
    ),
    FaqGroupData(
      accentColor: Color(0xFF00C950),
      title: 'Para Explicadores',
      questionCountText: '5 perguntas',
      questions: [],
      initiallyExpanded: false,
    ),
    FaqGroupData(
      accentColor: Color(0xFFFF6900),
      title: 'Pagamentos e Preços',
      questionCountText: '5 perguntas',
      questions: [],
      initiallyExpanded: false,
    ),
    FaqGroupData(
      accentColor: Color(0xFFAD46FF),
      title: 'Aulas e Tecnologia',
      questionCountText: '5 perguntas',
      questions: [],
      initiallyExpanded: false,
    ),
    FaqGroupData(
      accentColor: Color(0xFFFB2C36),
      title: 'Conta e Segurança',
      questionCountText: '5 perguntas',
      questions: [],
      initiallyExpanded: false,
    ),
  ];
}

/// Dados de uma categoria (pills/filtros) da FAQ.
class FaqCategoryData {
  const FaqCategoryData({
    required this.label,
    required this.icon,
    required this.width,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final double width;
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
