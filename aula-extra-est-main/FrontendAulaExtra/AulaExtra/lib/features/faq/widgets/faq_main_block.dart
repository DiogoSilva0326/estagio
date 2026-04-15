import 'package:aula_extra/features/faq/widgets/faq_category_row.dart';
import 'package:aula_extra/features/faq/widgets/faq_contact_card.dart';
import 'package:aula_extra/features/faq/widgets/faq_groups.dart';
import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqMainBlock extends StatelessWidget {
  const FaqMainBlock({
    super.key,
    required this.categories,
    required this.groups,
    required this.onCategoryTap,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
  });

  final List<FaqCategoryData> categories;
  final List<FaqGroupData> groups;
  final ValueChanged<String> onCategoryTap;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaqCategoryRow(categories: categories, onCategoryTap: onCategoryTap),
        const SizedBox(height: 61.252),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: FaqColors.orange),
            ),
          )
        else if (errorMessage != null)
          _FaqErrorState(errorMessage: errorMessage!, onRetry: onRetry)
        else
          FaqGroups(groups: groups),
        const SizedBox(height: 40.834),
        const FaqContactCard(),
      ],
    );
  }
}

class _FaqErrorState extends StatelessWidget {
  const _FaqErrorState({required this.errorMessage, this.onRetry});

  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
        border: Border.all(color: FaqColors.borderDefault, width: FaqDimens.borderThin),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 42, color: FaqColors.orange),
          const SizedBox(height: 16),
          const Text(
            'Não foi possível carregar as FAQs.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: FaqColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              height: 1.5,
              color: FaqColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ],
      ),
    );
  }
}
