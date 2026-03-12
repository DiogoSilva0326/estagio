import 'package:flutter/material.dart';

class ProgressoBar extends StatelessWidget {
  const ProgressoBar({
    super.key,
    required this.value,
    required this.color,
  });

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: SizedBox(
        height: 9.85,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: color.withValues(alpha: 0.20)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
