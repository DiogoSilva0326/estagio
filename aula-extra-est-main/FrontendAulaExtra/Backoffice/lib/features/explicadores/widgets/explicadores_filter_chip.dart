import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ExplicadoresFilterChip extends StatelessWidget {
  const ExplicadoresFilterChip({required this.label, this.width, super.key});

  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 42.515,
      padding: const EdgeInsets.symmetric(horizontal: 20.52),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.307),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.813,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3563,
        ),
      ),
    );
  }
}
