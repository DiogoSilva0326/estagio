import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_circle_icon.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_pill_bar.dart';
import 'package:aula_extra/features/faq/widgets/faq_mobile_search_bar.dart';
import 'package:flutter/material.dart';

class FaqMobileHeroSection extends StatelessWidget {
  const FaqMobileHeroSection({
    super.key,
    required this.searchController,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: FaqGradients.heroBackground,
        border: Border(
          bottom: BorderSide(
            color: FaqColors.borderLight,
            width: FaqDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          const FaqGradientCircleIcon(
            size: 72,
            iconSize: 34,
            icon: Icons.help_outline,
          ),
          const SizedBox(height: 18),
          const Text(
            FaqCopy.heroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              height: 1.0,
              fontWeight: FontWeight.w700,
              color: FaqColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const FaqGradientPillBar(width: 120, height: 4),
          const SizedBox(height: 18),
          const Text(
            FaqCopy.heroSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: FaqColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FaqMobileSearchBar(
            controller: searchController,
            onSearchPressed: onSearchPressed,
          ),
        ],
      ),
    );
  }
}
