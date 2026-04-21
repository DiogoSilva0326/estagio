import 'package:flutter/material.dart';

class SessaoLinkButton extends StatelessWidget {
  const SessaoLinkButton({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x1A41A7D7),
      borderRadius: BorderRadius.circular(11.648),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11.648),
        child: Container(
          height: 33.197,
          padding: const EdgeInsets.symmetric(horizontal: 13.979),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.login_rounded,
                size: 16.307,
                color: Color(0xFF41A7D7),
              ),
              const SizedBox(width: 11.648),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF41A7D7),
                  fontSize: 13.979,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
