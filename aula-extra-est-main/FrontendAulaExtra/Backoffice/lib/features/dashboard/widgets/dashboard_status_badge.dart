import 'package:flutter/material.dart';

class DashboardStatusBadge extends StatelessWidget {
  const DashboardStatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.showDot = false,
    super.key,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: showDot ? 12 : 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: showDot ? color.withValues(alpha: 0.18) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
