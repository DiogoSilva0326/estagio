import 'package:aula_extra/core/data/payments/dtos/student_topup_simulation_request_dto.dart';
import 'package:aula_extra/core/data/payments/payments_api.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_constants.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:aula_extra/features/comprar_creditos/sections/comprar_creditos_mobile_content_section.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_benefit_chip.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_package_card.dart';
import 'package:aula_extra/features/comprar_creditos/widgets/comprar_creditos_step_card.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComprarCreditosContentSection extends StatefulWidget {
  const ComprarCreditosContentSection({super.key});

  @override
  State<ComprarCreditosContentSection> createState() =>
      _ComprarCreditosContentSectionState();
}

class _ComprarCreditosContentSectionState
    extends State<ComprarCreditosContentSection> {
  final PaymentsService _paymentsService = PaymentsService();
  double _customCredits = 200;
  final GlobalKey _packagesSectionKey = GlobalKey();
  bool _isSubmitting = false;
  String? _submittingPackageName;

  Future<void> _scrollToPackagesSection() async {
    final context = _packagesSectionKey.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  double _parsePriceAmount(String priceLabel) {
    final normalized = priceLabel
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _goToCheckout(
    BuildContext context, {
    required int credits,
    required String packageName,
    required double paymentAmount,
  }) async {
    final role = context.read<UserProvider>().role;
    if (role == Role.student) {
      if (_isSubmitting) return;

      setState(() {
        _isSubmitting = true;
        _submittingPackageName = packageName;
      });

      try {
        final summary = await _paymentsService.simulateMyTopup(
          StudentTopupSimulationRequestDto(
            creditsAmount: credits.toDouble(),
            paymentAmount: paymentAmount,
            packageName: packageName,
            topupType: packageName,
          ),
        );

        if (!context.mounted) return;

        final provider = context.read<UserProvider>();
        provider.setAccount(
          (provider.account ?? const UserAccount()).copyWith(
            creditsBalance: summary.availableCredits,
            creditsCurrency: summary.currency,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$credits créditos adicionados com sucesso à tua conta.',
            ),
          ),
        );

        Navigator.of(context).pushNamed(Routes.pagamentos);
      } on PaymentsException catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível simular a compra de créditos.'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _submittingPackageName = null;
          });
        }
      }
      return;
    }

    Navigator.of(context).pushNamed(Routes.registerStudent);
  }

  Widget _buildPackagesRow(BuildContext context) {
    final cards = [
      for (final item in ComprarCreditosData.packages)
        ComprarCreditosPackageCard(
          data: item,
          buttonLabel: _isSubmitting && _submittingPackageName == item.title
              ? 'A processar...'
              : 'Comprar agora',
          isLoading: _isSubmitting,
          onPressed: () => _goToCheckout(
            context,
            credits: item.credits,
            packageName: item.title,
            paymentAmount: _parsePriceAmount(item.priceLabel),
          ),
        ),
      _CustomCreditsCard(
        credits: _customCredits.round(),
        onChanged: (value) => setState(() => _customCredits = value),
        buttonLabel:
            _isSubmitting && _submittingPackageName == 'Pack Personalizado'
            ? 'A processar...'
            : 'Comprar agora',
        isLoading: _isSubmitting,
        onPressed: () => _goToCheckout(
          context,
          credits: _customCredits.round(),
          packageName: 'Pack Personalizado',
          paymentAmount: _customCredits.roundToDouble(),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1320) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards,
          );
        }

        return Wrap(spacing: 18, runSpacing: 24, children: cards);
      },
    );
  }

  Widget _buildStepsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < ComprarCreditosData.steps.length; i++) ...[
                Expanded(
                  child: ComprarCreditosStepCard(
                    index: i + 1,
                    data: ComprarCreditosData.steps[i],
                  ),
                ),
                if (i != ComprarCreditosData.steps.length - 1)
                  const SizedBox(width: 28),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 28,
          runSpacing: 28,
          children: [
            for (var i = 0; i < ComprarCreditosData.steps.length; i++)
              ComprarCreditosStepCard(
                index: i + 1,
                data: ComprarCreditosData.steps[i],
                width: 390,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;
    final primaryLabel = isStudent
        ? 'Comprar créditos'
        : 'Criar conta para comprar';
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return ComprarCreditosMobileContentSection(
        primaryLabel: primaryLabel,
        packagesSectionKey: _packagesSectionKey,
        customCredits: _customCredits.round(),
        isSubmitting: _isSubmitting,
        submittingPackageName: _submittingPackageName,
        onPrimaryTap: _scrollToPackagesSection,
        onFaqTap: () => Navigator.of(context).pushNamed(Routes.faq),
        onCustomCreditsChanged: (value) =>
            setState(() => _customCredits = value),
        onPackageTap: (package) => _goToCheckout(
          context,
          credits: package.credits,
          packageName: package.title,
          paymentAmount: _parsePriceAmount(package.priceLabel),
        ),
        onCustomPackageTap: () => _goToCheckout(
          context,
          credits: _customCredits.round(),
          packageName: 'Pack Personalizado',
          paymentAmount: _customCredits.roundToDouble(),
        ),
      );
    }

    return Container(
      color: ComprarCreditosConstants.pageBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ComprarCreditosConstants.horizontalPadding,
          vertical: ComprarCreditosConstants.verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEÇÃO HERO (BANNER PRINCIPAL)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: ComprarCreditosConstants.heroBackground,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: ComprarCreditosConstants.cardBorder),
              ),
              child: Row(
                // ALINHAMENTO VERTICAL CENTRALIZADO PARA O CONTEÚDO E O CARD BRANCO
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Pacotes flexíveis para cada ritmo de estudo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ComprarCreditosConstants.highlight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Comprar créditos para marcares explicações quando quiseres.',
                          style: ComprarCreditosConstants.heroTitleStyle,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Escolhe o pacote certo para ti, carrega saldo em minutos e usa os créditos nas tuas próximas aulas com total flexibilidade.',
                          style: ComprarCreditosConstants.heroSubtitleStyle,
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: ComprarCreditosData.benefits
                              .map(
                                (benefit) =>
                                    ComprarCreditosBenefitChip(label: benefit),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF15C64),
                                    Color(0xFFFABD2D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ElevatedButton(
                                onPressed: _scrollToPackagesSection,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  primaryLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(Routes.faq),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 26,
                                  vertical: 18,
                                ),
                                side: const BorderSide(
                                  color: ComprarCreditosConstants.cardBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Ver perguntas frequentes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ComprarCreditosConstants.titleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                  // CARD BRANCO "PORQUE COMPRAR CRÉDITOS?"
                  Container(
                    width: 420,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140F172A),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Porque comprar créditos?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ComprarCreditosConstants.titleColor,
                          ),
                        ),
                        SizedBox(height: 18),
                        _HeroMetric(
                          value: '100%',
                          label:
                              'Flexibilidade para comprares apenas quando precisares',
                        ),
                        SizedBox(height: 18),
                        _HeroMetric(
                          value: '24/7',
                          label:
                              'Acesso ao saldo e histórico diretamente na tua conta',
                        ),
                        SizedBox(height: 18),
                        _HeroMetric(
                          value: 'Seguro',
                          label:
                              'Pagamentos simples com confirmação rápida e transparente',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ComprarCreditosConstants.sectionGap),
            Container(
              key: _packagesSectionKey,
              alignment: Alignment.centerLeft,
              child: const Text(
                'Escolhe o teu pacote',
                style: ComprarCreditosConstants.sectionTitleStyle,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Todos os pacotes dão acesso imediato a créditos para marcares explicações. Sem mensalidades e sem complicações.',
              style: ComprarCreditosConstants.sectionSubtitleStyle,
            ),
            const SizedBox(height: 28),
            _buildPackagesRow(context),
            const SizedBox(height: 56),
            const Text(
              'Como funciona',
              style: ComprarCreditosConstants.sectionTitleStyle,
            ),
            const SizedBox(height: 10),
            const Text(
              'Um processo simples para carregares a tua conta e começares logo a reservar aulas.',
              style: ComprarCreditosConstants.sectionSubtitleStyle,
            ),
            const SizedBox(height: 28),
            _buildStepsRow(),
            const SizedBox(height: 56),
            // BANNER FINAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: ComprarCreditosConstants.cardBorder),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pronto para reforçar o teu saldo?',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: ComprarCreditosConstants.titleColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Escolhe um pacote e segue para a área de pagamentos para concluires a compra ou criares a tua conta.',
                          style: ComprarCreditosConstants.sectionSubtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: _scrollToPackagesSection,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCreditsCard extends StatelessWidget {
  const _CustomCreditsCard({
    required this.credits,
    required this.onChanged,
    required this.onPressed,
    required this.buttonLabel,
    this.isLoading = false,
  });

  final int credits;
  final ValueChanged<double> onChanged;
  final VoidCallback onPressed;
  final String buttonLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 428,
      height: 548,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.057),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 41.786,
            offset: Offset(0, 20.893),
            spreadRadius: -10.029,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -16,
            child: Container(
              width: 177,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(27),
                  topRight: Radius.circular(20.057),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Personalizado',
                style: TextStyle(
                  fontSize: 17.872,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.192,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 105,
                    height: 105,
                    child: Center(
                      child: AssetPicture(
                        'public/images/Group 1321315079.svg',
                        width: 105,
                        height: 105,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pack Personalizado',
                            style: TextStyle(
                              fontSize: 29.179,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E2939),
                              letterSpacing: 0.3847,
                              height: 35.015 / 29.179,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Selecione o número\nde Créditos',
                            style: TextStyle(
                              fontSize: 23.981,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF364153),
                              letterSpacing: -0.2576,
                              height: 34.258 / 23.981,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$credits',
                    style: const TextStyle(
                      fontSize: 30.737,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFC9039),
                      letterSpacing: 0.4052,
                      height: 36.885 / 30.737,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AssetPicture(
                    'public/images/Group 1321315079.svg',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  activeTrackColor: const Color(0xFFF15C64),
                  inactiveTrackColor: const Color(0xFF737373),
                  thumbColor: Colors.black,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  min: 30,
                  max: 300,
                  divisions: 27,
                  value: credits.toDouble(),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Pack Personalizado:',
                    style: TextStyle(
                      fontSize: 18.199,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2939),
                      letterSpacing: 0.2399,
                      height: 21.838 / 18.199,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 58,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD1D5DC),
                        width: 1.111,
                      ),
                      borderRadius: BorderRadius.circular(4.445),
                    ),
                    child: Text(
                      '$credits€',
                      style: const TextStyle(
                        fontSize: 17.779,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0A0A0A),
                        letterSpacing: -0.3472,
                        height: 26.668 / 17.779,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(height: 1, color: Color(0xFFDDE2E8)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '$credits€',
                    style: const TextStyle(
                      fontSize: 50.219,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFC9039),
                      letterSpacing: 0.6621,
                      height: 60.262 / 50.219,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 186,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                        borderRadius: BorderRadius.circular(12.766),
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onPressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(172, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.766),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 20.426,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.3989,
                            height: 30.638 / 20.426,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: ComprarCreditosConstants.highlightSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ComprarCreditosConstants.highlight,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: ComprarCreditosConstants.subtitleColor,
            ),
          ),
        ),
      ],
    );
  }
}
