import 'package:flutter/material.dart';

import '../models/avaliacao_item.dart';

class AvaliacoesMockData {
  const AvaliacoesMockData._();

  static const double mediaGlobal = 4.8;
  static const int totalAvaliacoes = 1200;
  static const int pendentesModeracao = 14;

  static const List<AvaliacaoItem> items = [
    AvaliacaoItem(
      code: '#REV-302',
      aluno: 'Sofia Almeida',
      explicador: 'Carlos Ferreira',
      disciplina: 'Física',
      estrelas: 4,
      comment: 'Boa aula, mas podia ser mais objetiva na explicação final.',
      dateLabel: '11 Abr',
      status: AvaliacaoStatus.pendente,
      actions: [
        AvaliacaoAction(
          type: AvaliacaoActionType.aprovar,
          icon: Icons.check_rounded,
          backgroundColor: Color(0x1A12B76A),
          iconColor: Color(0xFF12B76A),
          tooltip: 'Aprovar avaliação',
        ),
        AvaliacaoAction(
          type: AvaliacaoActionType.rejeitar,
          icon: Icons.close_rounded,
          backgroundColor: Color(0x1AEF4444),
          iconColor: Color(0xFFEF4444),
          tooltip: 'Rejeitar avaliação',
        ),
      ],
    ),
    AvaliacaoItem(
      code: '#REV-301',
      aluno: 'Tiago Mendes',
      explicador: 'Ana Rodrigues',
      disciplina: 'Matemática',
      estrelas: 5,
      comment: 'Excelente explicação, recomendo muito!',
      dateLabel: '10 Abr',
      status: AvaliacaoStatus.aprovada,
      actions: [
        AvaliacaoAction(
          type: AvaliacaoActionType.detalhes,
          icon: Icons.visibility_outlined,
          backgroundColor: Color(0x1A4F46E5),
          iconColor: Color(0xFF4F46E5),
          tooltip: 'Ver detalhes',
        ),
      ],
    ),
    AvaliacaoItem(
      code: '#REV-300',
      aluno: 'Mariana Costa',
      explicador: 'Pedro Santos',
      disciplina: 'Inglês',
      estrelas: 3,
      comment: 'A sessão foi útil, mas houve alguns atrasos no início.',
      dateLabel: '09 Abr',
      status: AvaliacaoStatus.pendente,
      actions: [
        AvaliacaoAction(
          type: AvaliacaoActionType.aprovar,
          icon: Icons.check_rounded,
          backgroundColor: Color(0x1A12B76A),
          iconColor: Color(0xFF12B76A),
          tooltip: 'Aprovar avaliação',
        ),
        AvaliacaoAction(
          type: AvaliacaoActionType.rejeitar,
          icon: Icons.close_rounded,
          backgroundColor: Color(0x1AEF4444),
          iconColor: Color(0xFFEF4444),
          tooltip: 'Rejeitar avaliação',
        ),
      ],
    ),
    AvaliacaoItem(
      code: '#REV-299',
      aluno: 'João Ribeiro',
      explicador: 'Beatriz Lopes',
      disciplina: 'Biologia',
      estrelas: 5,
      comment: 'Muito clara e paciente. Ajudou bastante antes do teste.',
      dateLabel: '08 Abr',
      status: AvaliacaoStatus.aprovada,
      actions: [
        AvaliacaoAction(
          type: AvaliacaoActionType.detalhes,
          icon: Icons.visibility_outlined,
          backgroundColor: Color(0x1A4F46E5),
          iconColor: Color(0xFF4F46E5),
          tooltip: 'Ver detalhes',
        ),
      ],
    ),
  ];
}
