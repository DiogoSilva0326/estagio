import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_colors.dart';
import 'package:flutter/material.dart';

class MenuAlunoStatRow extends StatelessWidget {
  const MenuAlunoStatRow({
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
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              height: 20 / 17,
              fontWeight: FontWeight.w400,
              color: MenuAlunoColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              height: 20 / 17,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
