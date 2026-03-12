import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqCategoryRow extends StatelessWidget {
  const FaqCategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.53),
      child: Wrap(
        spacing: 15.313,
        runSpacing: 12.0,
        children: [
          for (int i = 0; i < FaqCopy.categories.length; i++)
            FaqCategoryPill(data: FaqCopy.categories[i]),
        ],
      ),
    );
  }
}

class FaqCategoryPill extends StatelessWidget {
  const FaqCategoryPill({super.key, required this.data});

  final FaqCategoryData data;

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
      constraints: BoxConstraints(minHeight: 48.491, minWidth: data.width),
      child: Container(
      width: data.width,
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 20.417),
      child: Row(
        children: [
          Icon(data.icon, size: 20.417, color: textColor),
          const SizedBox(width: 10.209),
          Expanded(
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
    );
  }
}
