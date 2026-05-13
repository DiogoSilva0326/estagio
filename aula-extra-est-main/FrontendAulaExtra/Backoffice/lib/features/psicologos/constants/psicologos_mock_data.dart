import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../explicadores/models/explicador_item.dart';

class PsicologosMockData {
  const PsicologosMockData._();

  static const List<String> filters = [
    'ESTADO: TODOS',
    'ESPECIALIDADE: TODAS',
    'VERIFICAÇÃO: TODOS',
  ];

  static const List<ExplicadorItem> items = [
    ExplicadorItem(
      initials: 'I',
      name: 'Inês Batista',
      email: 'ines.batista@email.com',
      mainSubject: 'Ansiedade Escolar',
      priceLabel: '€40/h',
      ratingLabel: '5.0 (14 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    ExplicadorItem(
      initials: 'T',
      name: 'Tiago Carvalho',
      email: 'tiago.carvalho@email.com',
      mainSubject: 'Orientação Vocacional',
      priceLabel: '€38/h',
      ratingLabel: '4.8 (7 aval.)',
      statusLabel: 'PENDENTE',
      statusColor: AppColors.warning,
      statusBackgroundColor: Color(0x26FB7B02),
      phone: '+351 931 554 876',
      location: 'Porto, Portugal',
      candidateMessage:
          '“Especializo-me em apoio emocional e orientação de jovens em contexto escolar, com foco em ansiedade, motivação e transições académicas.”',
      degreeTitle: 'Mestrado Integrado em Psicologia Clínica',
      degreeInstitution: 'Universidade de Coimbra',
      documentLabel: 'Cédula Profissional da OPP',
      documentActionLabel: 'Ver Documento',
      videoDuration: '1 min 58 seg',
      reviewStatusLabel: 'PENDENTE',
      reviewStatusColor: AppColors.warning,
      reviewStatusBackgroundColor: Color(0x26FB7B02),
      verifications: [
        ExplicadorVerificationItem(
          label: 'Cartão de Cidadão / Passaporte',
          icon: Icons.person_outline_rounded,
        ),
        ExplicadorVerificationItem(
          label: 'Cédula Profissional',
          icon: Icons.verified_user_outlined,
        ),
      ],
    ),
    ExplicadorItem(
      initials: 'S',
      name: 'Sara Coutinho',
      email: 'sara.coutinho@email.com',
      mainSubject: 'Gestão Emocional',
      priceLabel: '€42/h',
      ratingLabel: '4.9 (18 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
  ];
}
