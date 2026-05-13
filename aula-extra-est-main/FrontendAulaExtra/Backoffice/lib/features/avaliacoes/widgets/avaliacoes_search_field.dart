import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class AvaliacoesSearchField extends StatelessWidget {
  const AvaliacoesSearchField({
    super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320, minWidth: 240),
      height: 48.921,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3.494,
            offset: Offset(0, 1.165),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13.98),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18.637,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 13.98),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Pesquisar aluno, profissional ou comentario...',
                hintStyle: TextStyle(
                  color: Color(0x80101828),
                  fontSize: 16.307,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.18,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 16.307,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
