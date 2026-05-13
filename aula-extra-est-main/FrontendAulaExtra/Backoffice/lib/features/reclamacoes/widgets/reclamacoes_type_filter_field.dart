import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ReclamacoesTypeFilterField extends StatelessWidget {
  const ReclamacoesTypeFilterField({
    required this.types,
    required this.selectedType,
    required this.onChanged,
    super.key,
  });

  final List<String> types;
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 166, minWidth: 166),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3.494,
            offset: Offset(0, 1.165),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedType,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          hint: const Text(
            'Filtrar por: tipo',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos os tipos'),
            ),
            ...types.map(
              (type) => DropdownMenuItem<String?>(
                value: type,
                child: Text(type.toUpperCase()),
              ),
            ),
          ],
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
