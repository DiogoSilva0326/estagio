import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/dashboard_kpi_item.dart';

class DashboardMetricItem extends StatelessWidget {
  const DashboardMetricItem({required this.item, super.key});

  final DashboardKpiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.637),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.307,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.18,
                  ),
                ),
                const SizedBox(height: 4.6),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 34.944,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.41,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18.6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.307,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 60.569,
            height: 60.569,
            decoration: BoxDecoration(
              color: item.iconBackgroundColor,
              borderRadius: BorderRadius.circular(18.637),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 27.955),
          ),
        ],
      ),
    );
  }
}
