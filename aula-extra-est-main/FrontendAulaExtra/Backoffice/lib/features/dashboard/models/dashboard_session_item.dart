import 'package:flutter/material.dart';

class DashboardSessionItem {
  const DashboardSessionItem({
    required this.student,
    required this.tutor,
    required this.subject,
    required this.subjectIcon,
    required this.subjectColor,
    required this.subjectBackgroundColor,
    required this.dateLabel,
    required this.duration,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
    this.showStatusDot = false,
  });

  final String student;
  final String tutor;
  final String subject;
  final IconData subjectIcon;
  final Color subjectColor;
  final Color subjectBackgroundColor;
  final String dateLabel;
  final String duration;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
  final bool showStatusDot;
}
