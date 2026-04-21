import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class DashboardRefreshButton extends StatelessWidget {
  const DashboardRefreshButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.637),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18.637),
        child: Container(
          width: 53.581,
          height: 53.581,
          decoration: BoxDecoration(
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
          child: const Icon(
            Icons.refresh_rounded,
            size: 24,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
