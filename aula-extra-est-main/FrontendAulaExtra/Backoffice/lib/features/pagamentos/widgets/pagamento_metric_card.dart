import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';

class PagamentoMetricCard extends StatelessWidget {
  const PagamentoMetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.width,
    this.height,
    this.trailing,
    super.key,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double? width;
  final double? height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DashboardSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 29.12, vertical: 29.12),
        borderRadius: 27.955,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.307,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1752,
                        ),
                      ),
                      const SizedBox(height: 4.659),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60.569,
                  height: 60.569,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(18.636),
                  ),
                  child: Icon(icon, color: iconColor, size: 27.955),
                ),
              ],
            ),
            if (caption.isNotEmpty || trailing != null)
              const SizedBox(height: 18.637),
            if (caption.isNotEmpty || trailing != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: trailing != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    if (caption.isNotEmpty)
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.307,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1752,
                          height: 1.45,
                        ),
                      ),
                    ...?(trailing != null ? <Widget>[trailing!] : null),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
