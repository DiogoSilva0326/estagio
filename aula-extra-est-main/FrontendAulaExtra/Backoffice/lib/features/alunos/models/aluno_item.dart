import 'package:flutter/material.dart';

class AlunoItem {
  const AlunoItem({
    required this.initials,
    required this.name,
    required this.email,
    required this.schoolYear,
    required this.planLabel,
    required this.sessionsLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
  });

  final String initials;
  final String name;
  final String email;
  final String schoolYear;
  final String planLabel;
  final String sessionsLabel;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
}

class ExportCsvOptionItem {
  const ExportCsvOptionItem({
    required this.label,
    required this.description,
    this.isSelected = true,
  });

  final String label;
  final String description;
  final bool isSelected;
}
