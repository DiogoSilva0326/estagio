import 'package:flutter/material.dart';

class DashboardPopularSubjectItem {
  const DashboardPopularSubjectItem({
    required this.label,
    required this.professorCountLabel,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String label;
  final String professorCountLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
}
