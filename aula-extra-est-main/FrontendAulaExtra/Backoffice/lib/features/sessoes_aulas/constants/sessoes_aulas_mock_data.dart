import 'package:flutter/material.dart';

import '../models/sessao_aula_item.dart';

class SessoesAulasMockData {
  const SessoesAulasMockData._();

  static const List<String> filters = ['DATA: TODAS', 'ESTADO: TODOS'];

  static const List<SessaoAulaItem> sessoes = [
    SessaoAulaItem(
      codigo: '#AUL-1043',
      aluno: 'Sofia Almeida',
      explicador: 'Carlos Ferreira',
      disciplina: 'Física',
      dataHora: 'Hoje, 16:00',
      duracao: '45 min (decorrer)',
      linkSalaLabel: 'Entrar (Admin)',
      statusLabel: 'EM CURSO (LIVE)',
      statusColor: Color(0xFFFC9039),
      statusBackgroundColor: Color(0x1FFB7B02),
      showStatusDot: true,
      canEnterRoom: true,
    ),
    SessaoAulaItem(
      codigo: '#AUL-1042',
      aluno: 'João Silva',
      explicador: 'Ana Rodrigues',
      disciplina: 'Matemática',
      dataHora: 'Hoje, 14:30',
      duracao: '60 min',
      linkSalaLabel: '-',
      statusLabel: 'CONCLUÍDA',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    SessaoAulaItem(
      codigo: '#AUL-1041',
      aluno: 'Mariana Costa',
      explicador: 'Marta Oliveira',
      disciplina: 'Biologia',
      dataHora: 'Ontem, 18:00',
      duracao: '50 min',
      linkSalaLabel: '-',
      statusLabel: 'CONCLUÍDA',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
  ];
}
