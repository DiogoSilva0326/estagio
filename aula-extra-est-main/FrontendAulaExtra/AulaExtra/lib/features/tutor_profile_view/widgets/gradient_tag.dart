import 'package:flutter/material.dart';

class GradientTag extends StatelessWidget {
  const GradientTag({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61.277,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.766),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color.fromRGBO(252, 144, 57, 0.1), Color.fromRGBO(241, 92, 100, 0.1)],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20.426,
            height: 30.638 / 20.426,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2939),
          ),
        ),
      ),
    );
  }
}
