import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqMobileSearchBar extends StatelessWidget {
  const FaqMobileSearchBar({
    super.key,
    required this.controller,
    required this.onSearchPressed,
  });

  final TextEditingController controller;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FaqColors.borderDefault),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, size: 18, color: FaqColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearchPressed(),
              style: const TextStyle(
                fontSize: 15,
                height: 1.2,
                color: FaqColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: FaqCopy.searchPlaceholder,
                hintStyle: TextStyle(
                  fontSize: 15,
                  height: 1.2,
                  color: Color.fromRGBO(16, 24, 40, 0.45),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.all(6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: FaqGradients.orangeVertical,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSearchPressed,
                    borderRadius: BorderRadius.circular(16),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
