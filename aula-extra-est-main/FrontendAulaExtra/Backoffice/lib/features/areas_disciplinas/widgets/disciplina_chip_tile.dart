import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class DisciplinaChipTile extends StatelessWidget {
  const DisciplinaChipTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44.262,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18.637),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A5565),
          fontSize: 16.307,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1752,
        ),
      ),
    );
  }
}
