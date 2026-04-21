import 'package:flutter/material.dart';

enum PagamentoStatus { pago, pendente, emProcessamento }

class PagamentoItem {
  const PagamentoItem({
    required this.code,
    required this.dateLabel,
    required this.aluno,
    required this.explicador,
    required this.totalAmount,
    required this.commissionLabel,
    required this.teacherAmount,
    required this.status,
  });

  final String code;
  final String dateLabel;
  final String aluno;
  final String explicador;
  final String totalAmount;
  final String commissionLabel;
  final String teacherAmount;
  final PagamentoStatus status;

  String get statusLabel {
    switch (status) {
      case PagamentoStatus.pago:
        return 'Pago';
      case PagamentoStatus.pendente:
        return 'Pendente';
      case PagamentoStatus.emProcessamento:
        return 'Em processamento';
    }
  }

  Color get statusColor {
    switch (status) {
      case PagamentoStatus.pago:
        return const Color(0xFF027A48);
      case PagamentoStatus.pendente:
        return const Color(0xFFB54708);
      case PagamentoStatus.emProcessamento:
        return const Color(0xFF4F46E5);
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case PagamentoStatus.pago:
        return const Color(0xFFEAFBF3);
      case PagamentoStatus.pendente:
        return const Color(0xFFFFF4E5);
      case PagamentoStatus.emProcessamento:
        return const Color(0xFFEEF2FF);
    }
  }
}
