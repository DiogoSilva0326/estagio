import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_mobile_layout.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_mobile_benefit_chip.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_mobile_metric_row.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_mobile_package_card.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_mobile_step_card.dart';
import 'package:flutter/material.dart';

class ComprarCreditosMobileContentSection extends StatelessWidget {
  const ComprarCreditosMobileContentSection({
    super.key,
    required this.primaryLabel,
    required this.packagesSectionKey,
    required this.customCredits,
    required this.isSubmitting,
    required this.submittingPackageName,
    required this.onPrimaryTap,
    required this.onFaqTap,
    required this.onCustomCreditsChanged,
    required this.onPackageTap,
    required this.onCustomPackageTap,
  });

  final String primaryLabel;
  final GlobalKey packagesSectionKey;
  final int customCredits;
  final bool isSubmitting;
  final String? submittingPackageName;
  final VoidCallback onPrimaryTap;
  final VoidCallback onFaqTap;
  final ValueChanged<double> onCustomCreditsChanged;
  final void Function(CreditPackageData package) onPackageTap;
  final VoidCallback onCustomPackageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ComprarCreditosMobileLayout.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(
            primaryLabel: primaryLabel,
            onPrimaryTap: onPrimaryTap,
            onFaqTap: onFaqTap,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ComprarCreditosMobileLayout.horizontalPadding,
              ComprarCreditosMobileLayout.sectionGap,
              ComprarCreditosMobileLayout.horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: packagesSectionKey,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Escolhe o teu pacote',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      color: ComprarCreditosMobileLayout.titleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Todos os pacotes dão acesso aos mesmos créditos para marcares explicações. Sem mensalidades e sem complicações.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: ComprarCreditosMobileLayout.subtitleColor,
                  ),
                ),
                const SizedBox(height: 18),
                ...ComprarCreditosData.packages.map(
                  (package) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ComprarCreditosMobilePackageCard(
                      data: package,
                      buttonLabel:
                          isSubmitting && submittingPackageName == package.title
                          ? 'A processar...'
                          : 'Comprar agora',
                      isLoading:
                          isSubmitting &&
                          submittingPackageName == package.title,
                      onPressed: () => onPackageTap(package),
                    ),
                  ),
                ),
                ComprarCreditosMobileCustomPackageCard(
                  credits: customCredits,
                  buttonLabel:
                      isSubmitting &&
                          submittingPackageName == 'Pack Personalizado'
                      ? 'A processar...'
                      : 'Comprar agora',
                  isLoading:
                      isSubmitting &&
                      submittingPackageName == 'Pack Personalizado',
                  onChanged: onCustomCreditsChanged,
                  onPressed: onCustomPackageTap,
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'Como funciona',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      color: ComprarCreditosMobileLayout.titleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Um processo simples para carregares a tua conta e começares logo a reservar aulas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: ComprarCreditosMobileLayout.subtitleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                for (
                  var index = 0;
                  index < ComprarCreditosData.steps.length;
                  index++
                ) ...[
                  ComprarCreditosMobileStepCard(
                    index: index + 1,
                    data: ComprarCreditosData.steps[index],
                  ),
                  if (index != ComprarCreditosData.steps.length - 1)
                    const SizedBox(height: 16),
                ],
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: ComprarCreditosMobileLayout.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Pronto para reforçar o teu saldo?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: ComprarCreditosMobileLayout.titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Escolhe um pacote e deixa para a área de pagamentos para concluíres a compra ou criares a tua conta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: ComprarCreditosMobileLayout.subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: _PrimaryActionButton(
                          label: primaryLabel,
                          onPressed: onPrimaryTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.onFaqTap,
  });

  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback onFaqTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ComprarCreditosMobileLayout.heroGradientStart,
            ComprarCreditosMobileLayout.heroGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Pacotes flexíveis para cada ritmo de estudo',
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: ComprarCreditosMobileLayout.highlight,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Comprar créditos para marcares explicações quando quiseres.',
            style: TextStyle(
              fontSize: 36,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: ComprarCreditosMobileLayout.titleColor,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Escolhe o pacote certo para ti, carrega saldo em minutos e usa os créditos nas tuas próximas aulas com total flexibilidade.',
            style: TextStyle(
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: ComprarCreditosMobileLayout.subtitleColor,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ComprarCreditosData.benefits
                .map(
                  (benefit) => ComprarCreditosMobileBenefitChip(label: benefit),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _PrimaryActionButton(
              label: primaryLabel,
              onPressed: onPrimaryTap,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onFaqTap,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                side: const BorderSide(
                  color: ComprarCreditosMobileLayout.cardBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ComprarCreditosMobileLayout.buttonRadius,
                  ),
                ),
              ),
              child: const Text(
                'Ver perguntas frequentes',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF364153),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Porque comprar créditos?',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: ComprarCreditosMobileLayout.titleColor,
                  ),
                ),
                SizedBox(height: 16),
                ComprarCreditosMobileMetricRow(
                  value: '100%',
                  label:
                      'Flexibilidade para comprares apenas quando precisares',
                ),
                SizedBox(height: 16),
                ComprarCreditosMobileMetricRow(
                  value: '24/7',
                  label: 'Acesso ao saldo e histórico diretamente na tua conta',
                ),
                SizedBox(height: 16),
                ComprarCreditosMobileMetricRow(
                  value: 'Seguro',
                  label:
                      'Pagamentos simples com confirmação rápida e transparente',
                  useIcon: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
        ),
        borderRadius: BorderRadius.circular(
          ComprarCreditosMobileLayout.buttonRadius,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ComprarCreditosMobileLayout.buttonRadius,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
