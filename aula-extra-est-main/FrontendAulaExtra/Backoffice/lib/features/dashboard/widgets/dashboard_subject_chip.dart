import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class DashboardSubjectChip extends StatelessWidget {
  const DashboardSubjectChip({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.307, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A5565),
              fontSize: 13.978,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
