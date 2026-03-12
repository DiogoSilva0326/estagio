import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:flutter/material.dart';

class MenuProfessorStatRow extends StatelessWidget {
  const MenuProfessorStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29.545,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17.235,
              height: 24.621 / 17.235,
              fontWeight: FontWeight.w400,
              color: MenuProfessorColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 19.697,
              height: 29.545 / 19.697,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
