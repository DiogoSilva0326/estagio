/// Modelos e dados fake usados no ecrã de **Avaliações (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/avaliacoes/` para preencher a UI enquanto não há
///   integração com backend (protótipo / desenvolvimento).
///
/// Nota:
/// - Estes valores são apenas demonstrativos e devem ser substituídos por dados
///   reais vindos da API quando existir.
class AvaliacaoReview {
  const AvaliacaoReview({
    required this.tutorName,
    required this.subject,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });

  final String tutorName;
  final String subject;
  final double rating;
  final String comment;
  final String dateLabel;
}

class AvaliacoesMockData {
  const AvaliacoesMockData._();

  /// Média global apresentada no resumo.
  static const double mediaAvaliacoes = 4.8;

  /// Número de avaliações realizadas (para contadores/labels).
  static const int avaliacoesRealizadas = 3;

  /// Lista de reviews (cartões/linhas) mostradas na página.
  static const List<AvaliacaoReview> reviews = [
    AvaliacaoReview(
      tutorName: 'João Silva',
      subject: 'Matemática',
      rating: 5.0,
      comment:
          'Excelente explicador! Muito paciente e didático. Consegui entender conceitos que antes pareciam impossíveis.',
      dateLabel: '20 Jan 2026',
    ),
    AvaliacaoReview(
      tutorName: 'Maria Santos',
      subject: 'Física',
      rating: 4.5,
      comment:
          'Ótimas aulas, explica muito bem. Só acho que poderia disponibilizar mais exercícios.',
      dateLabel: '22 Jan 2026',
    ),
    AvaliacaoReview(
      tutorName: 'Pedro Costa',
      subject: 'Inglês',
      rating: 5.0,
      comment:
          'Perfeito! Melhorei muito meu inglês com as aulas dele. Recomendo muito!',
      dateLabel: '23 Jan 2026',
    ),
  ];
}
