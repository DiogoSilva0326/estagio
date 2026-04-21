import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqMobileCategoryChips extends StatelessWidget {
  const FaqMobileCategoryChips({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<FaqCategoryData> categories;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            _CategoryChip(
              data: category,
              onTap: () => onCategoryTap(category.id),
            ),
            if (category != categories.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.data, required this.onTap});

  final FaqCategoryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = data.selected
        ? const BoxDecoration(
            gradient: FaqGradients.orangeVertical,
            borderRadius: BorderRadius.all(
              Radius.circular(FaqDimens.radiusPill),
            ),
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(FaqDimens.radiusPill),
            ),
            border: Border.all(color: FaqColors.borderDefault),
          );

    final textColor = data.selected
        ? Colors.white
        : FaqColors.textButtonSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(FaqDimens.radiusPill),
        ),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
