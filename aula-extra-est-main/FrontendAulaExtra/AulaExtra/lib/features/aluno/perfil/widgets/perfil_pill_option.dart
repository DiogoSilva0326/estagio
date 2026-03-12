import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:flutter/material.dart';

class PerfilPillOption extends StatelessWidget {
  const PerfilPillOption({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.width,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: PerfilConstants.pillHeight,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        gradient: selected ? PerfilConstants.gradientOrange : null,
        color: selected ? null : PerfilConstants.softFill,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 22.247,
          fontWeight: FontWeight.w400,
          color: selected ? Colors.white : const Color(0xFF364153),
          height: 33.371 / 22.247,
        ),
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: child,
    );
  }
}
