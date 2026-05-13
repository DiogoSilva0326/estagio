import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/faq_item.dart';

class FaqsCategoryFilterField extends StatelessWidget {
  const FaqsCategoryFilterField({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    super.key,
  });

  final List<FaqCategoryOption> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190, minWidth: 190),
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
          value: selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          hint: const Text(
            'Categoria',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas as categorias'),
            ),
            ...categories.map(
              (category) => DropdownMenuItem<String?>(
                value: category.id,
                child: Text(category.label),
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
