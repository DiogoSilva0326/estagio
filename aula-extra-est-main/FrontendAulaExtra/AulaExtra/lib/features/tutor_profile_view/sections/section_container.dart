import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.title,
    required this.child,
    this.leadingIcon,
  });

  final String title;
  final Widget child;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 30.638, color: const Color(0xFF0A0A0A)),
              const SizedBox(width: 10.213),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 25.532,
                height: 35.745 / 25.532,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15.319),
        child,
      ],
    );
  }
}
