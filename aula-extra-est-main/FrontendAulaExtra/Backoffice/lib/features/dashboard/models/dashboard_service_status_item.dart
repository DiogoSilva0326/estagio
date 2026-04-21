import 'package:flutter/material.dart';

class DashboardServiceStatusItem {
  const DashboardServiceStatusItem({
    required this.label,
    required this.badgeLabel,
    required this.indicatorColor,
    required this.badgeColor,
    required this.badgeBackgroundColor,
  });

  final String label;
  final String badgeLabel;
  final Color indicatorColor;
  final Color badgeColor;
  final Color badgeBackgroundColor;
}
