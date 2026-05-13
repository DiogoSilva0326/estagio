import 'package:flutter/material.dart';

class PagamentoItem {
  const PagamentoItem({
    required this.id,
    required this.code,
    required this.subject,
    required this.paymentDate,
    required this.reference,
    required this.currency,
    required this.grossAmountValue,
    required this.platformFeeAmountValue,
    required this.teacherAmountValue,
    required this.dateLabel,
    required this.aluno,
    required this.explicador,
    required this.totalAmount,
    required this.commissionLabel,
    required this.teacherAmount,
    required this.status,
  });

  final String id;
  final String code;
  final String subject;
  final DateTime? paymentDate;
  final String reference;
  final String currency;
  final double grossAmountValue;
  final double platformFeeAmountValue;
  final double teacherAmountValue;
  final String dateLabel;
  final String aluno;
  final String explicador;
  final String totalAmount;
  final String commissionLabel;
  final String teacherAmount;
  final String status;

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'pago':
      case 'success':
      case 'succeeded':
        return 'Pago';
      case 'pending':
      case 'pendente':
        return 'Pendente';
      case 'processing':
      case 'em processamento':
      case 'in_process':
        return 'Em processamento';
      default:
        return 'Pendente';
    }
  }

  Color get statusColor {
    switch (statusLabel) {
      case 'Pago':
        return const Color(0xFF027A48);
      case 'Pendente':
        return const Color(0xFFB54708);
      case 'Em processamento':
      default:
        return const Color(0xFF4F46E5);
    }
  }

  Color get statusBackgroundColor {
    switch (statusLabel) {
      case 'Pago':
        return const Color(0xFFEAFBF3);
      case 'Pendente':
        return const Color(0xFFFFF4E5);
      case 'Em processamento':
      default:
        return const Color(0xFFEEF2FF);
    }
  }
}
