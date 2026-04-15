import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqCategoryRow extends StatelessWidget {
  const FaqCategoryRow({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<FaqCategoryData> categories;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 48.53),
      child: Wrap(
        spacing: 15.313,
        runSpacing: 12.0,
        children: [
          for (final category in categories)
            FaqCategoryPill(
              data: category,
              onTap: () => onCategoryTap(category.id),
            ),
        ],
      ),
    );
  }
}

class FaqCategoryPill extends StatelessWidget {
  const FaqCategoryPill({
    super.key,
    required this.data,
    required this.onTap,
  });

  final FaqCategoryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = data.selected
        ? BoxDecoration(
            gradient: FaqGradients.orangeVertical,
            borderRadius: const BorderRadius.all(Radius.circular(FaqDimens.radiusPill)),
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(FaqDimens.radiusPill)),
            border: Border.all(color: FaqColors.borderDefault, width: FaqDimens.borderThin),
          );

    final textColor = data.selected ? Colors.white : FaqColors.textButtonSecondary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.491),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(
            Radius.circular(FaqDimens.radiusPill),
          ),
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.417,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, size: 20.417, color: textColor),
                const SizedBox(width: 10.209),
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17.865,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
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
