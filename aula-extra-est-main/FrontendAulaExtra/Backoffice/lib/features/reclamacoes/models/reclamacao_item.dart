import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ReclamacaoStatusStyle {
  const ReclamacaoStatusStyle({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}

extension ReclamacaoStatusMapper on String {
  ReclamacaoStatusStyle toReclamacaoStatusStyle() {
    switch (trim().toLowerCase()) {
      case 'lida':
        return const ReclamacaoStatusStyle(
          label: 'Lida',
          color: AppColors.accent,
          backgroundColor: Color(0xFFEEF2FF),
        );
      case 'respondida':
        return const ReclamacaoStatusStyle(
          label: 'Respondida',
          color: AppColors.success,
          backgroundColor: Color(0xFFEAFBF3),
        );
      case 'pending':
      case 'pendente':
      case 'submetida':
        return const ReclamacaoStatusStyle(
          label: 'Pendente',
          color: AppColors.warning,
          backgroundColor: Color(0xFFFFF4E5),
        );
      case 'in_analysis':
      case 'em análise':
      case 'em analise':
      case 'in review':
        return const ReclamacaoStatusStyle(
          label: 'Em análise',
          color: AppColors.accent,
          backgroundColor: Color(0xFFEEF2FF),
        );
      case 'resolved':
      case 'resolvida':
      case 'closed':
      case 'fechada':
        return const ReclamacaoStatusStyle(
          label: 'Resolvida',
          color: AppColors.success,
          backgroundColor: Color(0xFFEAFBF3),
        );
      case 'archived':
      case 'arquivada':
        return const ReclamacaoStatusStyle(
          label: 'Arquivada',
          color: AppColors.textSecondary,
          backgroundColor: Color(0xFFF3F4F6),
        );
      default:
        return const ReclamacaoStatusStyle(
          label: 'Aberta',
          color: AppColors.textPrimary,
          backgroundColor: Color(0xFFF3F4F6),
        );
    }
  }
}

enum ReclamacaoSource {
  utilizadores,
  pagamentos,
}

class ReclamacaoItem {
  const ReclamacaoItem({
    required this.id,
    required this.source,
    required this.dateLabel,
    required this.profileName,
    required this.profileEmail,
    required this.type,
    required this.statusRaw,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
    required this.title,
    required this.description,
  });

  final String id;
  final ReclamacaoSource source;
  final String dateLabel;
  final String profileName;
  final String profileEmail;
  final String type;
  final String statusRaw;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
  final String title;
  final String description;
}
