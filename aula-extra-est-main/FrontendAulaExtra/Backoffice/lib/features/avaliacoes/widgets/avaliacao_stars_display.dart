import 'package:flutter/material.dart';

class AvaliacaoStarsDisplay extends StatelessWidget {
  const AvaliacaoStarsDisplay({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List<Widget>.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(right: index == 4 ? 0 : 2.33),
            child: Icon(
              Icons.star_rounded,
              size: 18.637,
              color: index < value
                  ? const Color(0xFFF79009)
                  : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        const SizedBox(width: 9.318),
        Text(
          '(${value.toStringAsFixed(1)})',
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 15.143,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }
}
