import 'package:flutter/material.dart';

class BulletRow extends StatelessWidget {
  const BulletRow({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 25.532, color: const Color(0xFF0A0A0A)),
        const SizedBox(width: 15.319),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20.426,
              height: 30.638 / 20.426,
              fontWeight: FontWeight.w400,
              color: Color(0xFF364153),
            ),
          ),
        ),
      ],
    );
  }
}
