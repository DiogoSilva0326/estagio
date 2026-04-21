import 'package:flutter/material.dart';

enum AvaliacaoStatus { pendente, aprovada, rejeitada }

enum AvaliacaoActionType { aprovar, rejeitar, detalhes }

class AvaliacaoAction {
  const AvaliacaoAction({
    required this.type,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.tooltip,
  });

  final AvaliacaoActionType type;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String tooltip;
}

class AvaliacaoItem {
  const AvaliacaoItem({
    required this.code,
    required this.aluno,
    required this.explicador,
    required this.disciplina,
    required this.estrelas,
    required this.comment,
    required this.dateLabel,
    required this.status,
    required this.actions,
  });

  final String code;
  final String aluno;
  final String explicador;
  final String disciplina;
  final int estrelas;
  final String comment;
  final String dateLabel;
  final AvaliacaoStatus status;
  final List<AvaliacaoAction> actions;

  String get statusLabel {
    switch (status) {
      case AvaliacaoStatus.pendente:
        return 'Pendente';
      case AvaliacaoStatus.aprovada:
        return 'Aprovada';
      case AvaliacaoStatus.rejeitada:
        return 'Rejeitada';
    }
  }

  Color get statusColor {
    switch (status) {
      case AvaliacaoStatus.pendente:
        return const Color(0xFFB54708);
      case AvaliacaoStatus.aprovada:
        return const Color(0xFF027A48);
      case AvaliacaoStatus.rejeitada:
        return const Color(0xFFB42318);
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case AvaliacaoStatus.pendente:
        return const Color(0xFFFFF4E5);
      case AvaliacaoStatus.aprovada:
        return const Color(0xFFEAFBF3);
      case AvaliacaoStatus.rejeitada:
        return const Color(0xFFFEECEC);
    }
  }
}
