import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/explicador_item.dart';

class ExplicadoresMockData {
  const ExplicadoresMockData._();

  static const List<String> filters = [
    'ESTADO: TODOS',
    'ÁREA: TODAS',
    'VERIFICAÇÃO: TODOS',
  ];

  static const List<ExplicadorItem> explicadores = [
    ExplicadorItem(
      initials: 'A',
      name: 'Ana Rodrigues',
      email: 'ana.rodrigues@email.com',
      mainSubject: 'Matemática',
      priceLabel: '€25/h',
      ratingLabel: '5.0 (12 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    ExplicadorItem(
      initials: 'C',
      name: 'Carlos Ferreira',
      email: 'carlos.f@email.com',
      mainSubject: 'Física',
      priceLabel: '€30/h',
      ratingLabel: '4.8 (8 aval.)',
      statusLabel: 'PENDENTE',
      statusColor: AppColors.warning,
      statusBackgroundColor: Color(0x26FB7B02),
      phone: '+351 912 345 678',
      location: 'Lisboa, Portugal (Remoto)',
      candidateMessage:
          '"Tenho 5 anos de experiência a dar explicações a alunos do secundário e adoro partilhar o meu gosto pela física de uma forma prática e próxima da realidade."',
      degreeTitle: 'Mestrado em Engenharia Física',
      degreeInstitution: 'Faculdade de Ciências da Univ. do Porto',
      documentLabel: 'Certificado Anexado (PDF)',
      documentActionLabel: 'Ver Documento',
      videoDuration: '1 min 45 seg',
      reviewStatusLabel: 'PENDENTE',
      reviewStatusColor: AppColors.warning,
      reviewStatusBackgroundColor: Color(0x26FB7B02),
      verifications: [
        ExplicadorVerificationItem(
          label: 'Cartão de Cidadão / Passaporte',
          icon: Icons.person_outline_rounded,
        ),
        ExplicadorVerificationItem(
          label: 'Registo Criminal',
          icon: Icons.description_outlined,
        ),
      ],
    ),
    ExplicadorItem(
      initials: 'M',
      name: 'Marta Oliveira',
      email: 'marta.oliveira@email.com',
      mainSubject: 'Biologia',
      priceLabel: '€28/h',
      ratingLabel: '4.9 (15 aval.)',
      statusLabel: 'ATIVO',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
  ];
}
