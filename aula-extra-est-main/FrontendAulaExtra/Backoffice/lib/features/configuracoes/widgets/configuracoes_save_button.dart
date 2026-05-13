import 'package:flutter/material.dart';

class ConfiguracoesSaveButton extends StatelessWidget {
  const ConfiguracoesSaveButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(16.307),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16.307,
            offset: Offset(0, 4.659),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save_outlined, size: 18.637),
        label: const Text('Guardar Alterações'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 23.3,
            vertical: 13.98,
          ),
          textStyle: const TextStyle(
            fontSize: 16.307,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1752,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.307),
          ),
        ),
      ),
    );
  }
}
