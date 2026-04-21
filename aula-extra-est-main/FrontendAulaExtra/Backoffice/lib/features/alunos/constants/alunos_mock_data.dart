import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/aluno_item.dart';

class AlunosMockData {
  const AlunosMockData._();

  static const List<String> filters = [
    'ESTADO: TODOS',
    'ANO: TODOS',
    'PLANO: TODOS',
  ];

  static const List<AlunoItem> alunos = [
    AlunoItem(
      initials: 'M',
      name: 'Mariana Costa',
      email: 'mariana.costa@email.com',
      schoolYear: '12º Ano',
      planLabel: 'Premium',
      sessionsLabel: '24 sessões',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    AlunoItem(
      initials: 'J',
      name: 'João Almeida',
      email: 'joao.almeida@email.com',
      schoolYear: '10º Ano',
      planLabel: 'Standard',
      sessionsLabel: '10 sessões',
      statusLabel: 'EM RISCO',
      statusColor: AppColors.warning,
      statusBackgroundColor: Color(0x26FB7B02),
    ),
    AlunoItem(
      initials: 'I',
      name: 'Inês Martins',
      email: 'ines.martins@email.com',
      schoolYear: 'Universidade',
      planLabel: 'Premium',
      sessionsLabel: '31 sessões',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
  ];

  static const List<ExportCsvOptionItem> exportOptions = [
    ExportCsvOptionItem(
      label: 'Dados pessoais',
      description: 'Nome, email e identificadores do aluno.',
    ),
    ExportCsvOptionItem(
      label: 'Estado e plano',
      description: 'Plano atual, estado da conta e renovação.',
    ),
    ExportCsvOptionItem(
      label: 'Histórico de sessões',
      description: 'Número de sessões marcadas e concluídas.',
    ),
    ExportCsvOptionItem(
      label: 'Financeiro',
      description: 'Pagamentos associados e saldo da conta.',
      isSelected: false,
    ),
  ];
}
