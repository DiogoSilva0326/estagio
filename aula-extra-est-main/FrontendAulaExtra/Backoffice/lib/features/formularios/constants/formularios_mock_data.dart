import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/formulario_item.dart';

class FormulariosMockData {
  const FormulariosMockData._();

  static const List<FormularioItem> items = [
    FormularioItem(
      submissionId: '938279',
      id: '#938279',
      dateLabel: '13 Abr',
      profileName: 'Tiago Mendes',
      profileEmail: 'tiago.mendes@email.pt',
      formName: 'Pedido de contacto',
      statusRaw: 'não lida',
      statusLabel: 'Pendente',
      statusColor: AppColors.warning,
      statusBackgroundColor: Color(0xFFFFF4E5),
      message:
          'Olá, gostaria de saber mais sobre apoio para exames nacionais de Matemática A.',
    ),
    FormularioItem(
      submissionId: '938280',
      id: '#938280',
      dateLabel: '13 Abr',
      profileName: 'Carla Santos',
      profileEmail: 'carla.santos@email.pt',
      formName: 'Quero ser explicador',
      statusRaw: 'respondida',
      statusLabel: 'Respondido',
      statusColor: AppColors.success,
      statusBackgroundColor: Color(0xFFEAFBF3),
      message:
          'Submeti a minha candidatura como explicadora de FQ e Biologia. Gostava de acompanhar o estado.',
    ),
    FormularioItem(
      submissionId: '938281',
      id: '#938281',
      dateLabel: '12 Abr',
      profileName: 'Inês Rocha',
      profileEmail: 'ines.rocha@email.pt',
      formName: 'Sugestão / melhoria',
      statusRaw: 'lida',
      statusLabel: 'Novo',
      statusColor: AppColors.accent,
      statusBackgroundColor: Color(0xFFEEF2FF),
      message:
          'Seria útil ter histórico de sessões diretamente no perfil do aluno com mais detalhe.',
    ),
    FormularioItem(
      submissionId: '938282',
      id: '#938282',
      dateLabel: '11 Abr',
      profileName: 'Miguel Costa',
      profileEmail: 'miguel.costa@email.pt',
      formName: 'Pedido de contacto',
      statusRaw: 'arquivada',
      statusLabel: 'Arquivado',
      statusColor: AppColors.textSecondary,
      statusBackgroundColor: Color(0xFFF3F4F6),
      message:
          'Preciso de apoio semanal de Português para o 12.º ano. Podem indicar explicadores disponíveis?',
    ),
  ];
}
