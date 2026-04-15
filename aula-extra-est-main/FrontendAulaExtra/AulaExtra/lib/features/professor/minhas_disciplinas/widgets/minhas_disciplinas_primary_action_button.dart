import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasPrimaryActionButton extends StatelessWidget {
  const MinhasDisciplinasPrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MinhasDisciplinasProfessorLayout.primaryButtonWidth,
      height: MinhasDisciplinasProfessorLayout.primaryButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            MinhasDisciplinasProfessorLayout.primaryButtonRadius,
          ),
          gradient: const LinearGradient(
            colors: [
              MinhasDisciplinasProfessorColors.buttonGradientTop,
              MinhasDisciplinasProfessorColors.buttonGradientBottom,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6.848,
              offset: const Offset(0, 4.566),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.566,
              offset: const Offset(0, 2.283),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              MinhasDisciplinasProfessorLayout.primaryButtonRadius,
            ),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22.828, color: Colors.white),
                const SizedBox(width: 9.131),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.262,
                    height: 27.394 / 18.262,
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
