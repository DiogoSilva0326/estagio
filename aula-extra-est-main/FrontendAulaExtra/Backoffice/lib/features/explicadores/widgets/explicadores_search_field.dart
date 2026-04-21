import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ExplicadoresSearchField extends StatelessWidget {
  const ExplicadoresSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 298.187, minWidth: 240),
      height: 48.921,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3.494,
            offset: Offset(0, 1.165),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13.98),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 18.637, color: AppColors.textMuted),
          SizedBox(width: 13.98),
          Expanded(
            child: Text(
              'Pesquisar...',
              style: TextStyle(
                color: Color(0x80101828),
                fontSize: 16.307,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
