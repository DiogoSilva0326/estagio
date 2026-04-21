import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class DashboardSurfaceCard extends StatelessWidget {
  const DashboardSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius = 28,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
