import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/dashboard_popular_subject_item.dart';

class DashboardPopularSubjectRow extends StatelessWidget {
  const DashboardPopularSubjectRow({required this.item, super.key});

  final DashboardPopularSubjectItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.143),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.637)),
      child: Row(
        children: [
          Container(
            width: 41.933,
            height: 41.933,
            decoration: BoxDecoration(
              color: item.iconBackgroundColor,
              borderRadius: BorderRadius.circular(16.307),
            ),
            child: Icon(item.icon, size: 18.637, color: item.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF1E2939),
                fontSize: 16.307,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.18,
              ),
            ),
          ),
          Text(
            item.professorCountLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.978,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
