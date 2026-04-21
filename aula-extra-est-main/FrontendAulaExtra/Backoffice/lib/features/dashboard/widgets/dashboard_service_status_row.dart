import 'package:flutter/material.dart';

import '../models/dashboard_service_status_item.dart';
import 'dashboard_status_badge.dart';

class DashboardServiceStatusRow extends StatelessWidget {
  const DashboardServiceStatusRow({required this.item, super.key});

  final DashboardServiceStatusItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11.648,
          height: 11.648,
          decoration: BoxDecoration(
            color: item.indicatorColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: item.indicatorColor.withValues(alpha: 0.6),
                blurRadius: 14,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF364153),
              fontSize: 16.307,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.18,
            ),
          ),
        ),
        DashboardStatusBadge(
          label: item.badgeLabel,
          color: item.badgeColor,
          backgroundColor: item.badgeBackgroundColor,
        ),
      ],
    );
  }
}
