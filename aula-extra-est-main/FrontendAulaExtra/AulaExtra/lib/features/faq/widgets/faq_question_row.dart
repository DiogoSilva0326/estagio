import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:flutter/material.dart';

class FaqQuestionRow extends StatelessWidget {
  const FaqQuestionRow({
    super.key,
    required this.index,
    required this.question,
    required this.answer,
    required this.showBottomBorder,
    required this.expanded,
    this.onTap,
  });

  final int index;
  final String question;
  final String answer;
  final bool showBottomBorder;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bottomBorder = showBottomBorder
        ? const Border(
            bottom: BorderSide(color: FaqColors.borderLight, width: FaqDimens.borderThin),
          )
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: bottomBorder),
        padding: const EdgeInsets.symmetric(horizontal: 25.522, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.626,
                  height: 30.626,
                  decoration: BoxDecoration(
                    color: FaqColors.questionIndexBg,
                    borderRadius: BorderRadius.circular(FaqDimens.radiusPill),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 15.313,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: FaqColors.questionIndexText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15.313),
                Expanded(
                  child: Text(
                    question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20.417,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: FaqColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 20.417),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 25.522,
                    color: FaqColors.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topLeft,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 46.0, top: 12.0, right: 10.0),
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontSize: 17.865,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          color: FaqColors.textSecondary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
