import 'package:aula_extra/features/explicadores/constants/explicadores_mobile_layout.dart';
import 'package:flutter/material.dart';

class ExplicadoresMobileHeroSection extends StatelessWidget {
  const ExplicadoresMobileHeroSection({
    super.key,
    required this.onCustomizeTap,
  });

  final VoidCallback onCustomizeTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: ExplicadoresMobileLayout.heroGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ExplicadoresMobileLayout.pageHorizontalPadding,
          ExplicadoresMobileLayout.heroTopPadding,
          ExplicadoresMobileLayout.pageHorizontalPadding,
          ExplicadoresMobileLayout.heroBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apoio Especializado',
              style: TextStyle(
                fontSize: 32,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Encontra o apoio perfeito para ti, desde explicadores a tutores e psicólogos. Personaliza a tua busca por preço, disponibilidade e mais.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const _HeroStatRow(
              icon: Icons.people_alt_outlined,
              label: '500+ profissionais disponíveis',
            ),
            const SizedBox(height: 12),
            const _HeroStatRow(
              icon: Icons.star_border_rounded,
              label: '4.7 estrelas médias',
            ),
            const SizedBox(height: 12),
            const _HeroStatRow(
              icon: Icons.play_circle_outline_rounded,
              label: '50.000+ sessões realizadas',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: ExplicadoresMobileLayout.heroButtonHeight,
              child: ElevatedButton(
                onPressed: onCustomizeTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: ExplicadoresMobileLayout.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Personalizar Resultados',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.33,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  const _HeroStatRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}