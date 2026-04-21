import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class CalendarioMobileCtaButton extends StatelessWidget {
  const CalendarioMobileCtaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.add_rounded,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: CalendarioConstants.orangeGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: CalendarioConstants.mobileShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 24 / 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
