import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../explicadores/models/explicador_item.dart';

class TutoresMockData {
  const TutoresMockData._();

  static const List<String> filters = [
    'ESTADO: TODOS',
    'ÁREA: TODAS',
    'VERIFICAÇÃO: TODOS',
  ];

  static const List<ExplicadorItem> items = [
    ExplicadorItem(
      initials: 'L',
      name: 'Luísa Almeida',
      email: 'luisa.almeida@email.com',
      mainSubject: 'Apoio ao Estudo',
      priceLabel: '€22/h',
      ratingLabel: '4.9 (19 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    ExplicadorItem(
      initials: 'R',
      name: 'Rui Matos',
      email: 'rui.matos@email.com',
      mainSubject: 'Métodos de Estudo',
      priceLabel: '€24/h',
      ratingLabel: '4.7 (11 aval.)',
      statusLabel: 'PENDENTE',
      statusColor: AppColors.warning,
      statusBackgroundColor: Color(0x26FB7B02),
      phone: '+351 918 245 001',
      location: 'Braga, Portugal',
      candidateMessage:
          '“Acompanho alunos do 2.º e 3.º ciclo na organização do estudo, técnicas de memorização e melhoria da autonomia escolar.”',
      degreeTitle: 'Mestrado em Ciências da Educação',
      degreeInstitution: 'Universidade do Minho',
      documentLabel: 'Certificado Pedagógico (PDF)',
      documentActionLabel: 'Ver Documento',
      videoDuration: '2 min 10 seg',
      reviewStatusLabel: 'PENDENTE',
      reviewStatusColor: AppColors.warning,
      reviewStatusBackgroundColor: Color(0x26FB7B02),
      verifications: [
        ExplicadorVerificationItem(
          label: 'Cartão de Cidadão / Passaporte',
          icon: Icons.person_outline_rounded,
        ),
        ExplicadorVerificationItem(
          label: 'Certificado de Habilitações',
          icon: Icons.school_outlined,
        ),
      ],
    ),
    ExplicadorItem(
      initials: 'M',
      name: 'Mónica Faria',
      email: 'monica.faria@email.com',
      mainSubject: 'Técnicas de Concentração',
      priceLabel: '€26/h',
      ratingLabel: '5.0 (9 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
  ];
}
