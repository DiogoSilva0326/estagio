import 'package:flutter/material.dart';

class FormularioItem {
  const FormularioItem({
    required this.submissionId,
    required this.id,
    required this.dateLabel,
    required this.profileName,
    required this.profileEmail,
    required this.formName,
    required this.statusRaw,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
    required this.message,
  });

  final String submissionId;
  final String id;
  final String dateLabel;
  final String profileName;
  final String profileEmail;
  final String formName;
  final String statusRaw;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
  final String message;
}
