import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_mobile_category_chips.dart';
import 'package:aula_extra/features/faq/widgets/faq_mobile_contact_card.dart';
import 'package:aula_extra/features/faq/widgets/faq_mobile_groups.dart';
import 'package:aula_extra/features/faq/widgets/faq_mobile_hero_section.dart';
import 'package:flutter/material.dart';

class FaqMobileContentSection extends StatelessWidget {
  const FaqMobileContentSection({
    super.key,
    required this.searchController,
    required this.onSearchPressed,
    required this.categories,
    required this.groups,
    required this.onCategoryTap,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;
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
        FaqMobileHeroSection(
          searchController: searchController,
          onSearchPressed: onSearchPressed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolhe uma categoria ou explora todas as perguntas frequentes.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF4A5565),
                ),
              ),
              const SizedBox(height: 16),
              FaqMobileCategoryChips(
                categories: categories,
                onCategoryTap: onCategoryTap,
              ),
              const SizedBox(height: 24),
              const Text(
                'Perguntas',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Encontra respostas rápidas para as dúvidas mais comuns.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF4A5565),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                  ),
                )
              else if (errorMessage != null)
                _FaqMobileErrorState(
                  errorMessage: errorMessage!,
                  onRetry: onRetry,
                )
              else
                FaqMobileGroups(groups: groups),
              const SizedBox(height: 24),
              const FaqMobileContactCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqMobileErrorState extends StatelessWidget {
  const _FaqMobileErrorState({required this.errorMessage, this.onRetry});

  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 38, color: Color(0xFFFF6B00)),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível carregar as FAQs.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFF4A5565),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
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
