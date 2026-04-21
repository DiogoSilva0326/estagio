import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:flutter/material.dart';

class AvaliacoesMobileCtaCard extends StatelessWidget {
  const AvaliacoesMobileCtaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AvaliacoesConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(
          AvaliacoesConstants.mobileCardRadius,
        ),
        border: Border.all(
          color: AvaliacoesConstants.mobilePrimaryColor,
          width: 1.5,
        ),
        boxShadow: AvaliacoesConstants.mobileShadow,
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AvaliacoesConstants.mobileCardTitleStyle.copyWith(
              fontSize: 17,
              height: 24 / 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AvaliacoesConstants.mobileBodyStyle.copyWith(
              fontSize: 13,
              height: 18 / 13,
              color: AvaliacoesConstants.mobileMutedColor,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AvaliacoesConstants.orangeGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 18 / 13,
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
