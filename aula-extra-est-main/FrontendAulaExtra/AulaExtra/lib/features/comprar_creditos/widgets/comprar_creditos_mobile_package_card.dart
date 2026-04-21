import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ComprarCreditosMobilePackageCard extends StatelessWidget {
  const ComprarCreditosMobilePackageCard({
    super.key,
    required this.data,
    required this.buttonLabel,
    required this.onPressed,
    this.isLoading = false,
  });

  final CreditPackageData data;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: BoxDecoration(
        color: ComprarCreditosMobileLayout.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (data.badge != null)
            Positioned(
              top: -26,
              left: -20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: data.badgeColor,
                  gradient: data.badgeColor == null
                      ? const LinearGradient(
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        )
                      : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  data.badge!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Column(
            children: [
              if (data.badge != null) const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                    width: 74,
                    height: 74,
                    child: AssetPicture(
                      'public/images/Group 1321315079.svg',
                      width: 74,
                      height: 74,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: ComprarCreditosMobileLayout.titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.credits} Créditos',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF364153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                data.caption,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF364153),
                ),
              ),
              const SizedBox(height: 14),
              ...data.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    feature.startsWith('Preço unitário')
                        ? feature
                        : '✓ $feature',
                    style: TextStyle(
                      fontSize: feature.startsWith('Preço unitário') ? 13 : 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: feature.startsWith('Preço unitário')
                          ? ComprarCreditosMobileLayout.mutedColor
                          : const Color(0xFF364153),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFDDE2E8)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      data.priceLabel,
                      style: const TextStyle(
                        fontSize: 38,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: ComprarCreditosMobileLayout.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ComprarAgoraButton(
                    label: buttonLabel,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : onPressed,
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

class ComprarCreditosMobileCustomPackageCard extends StatelessWidget {
  const ComprarCreditosMobileCustomPackageCard({
    super.key,
    required this.credits,
    required this.buttonLabel,
    required this.onChanged,
    required this.onPressed,
    this.isLoading = false,
  });

  final int credits;
  final String buttonLabel;
  final ValueChanged<double> onChanged;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: BoxDecoration(
        color: ComprarCreditosMobileLayout.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -26,
            left: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Text(
                'Personalizado',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                    width: 74,
                    height: 74,
                    child: AssetPicture(
                      'public/images/Group 1321315079.svg',
                      width: 74,
                      height: 74,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pack Personalizado',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: ComprarCreditosMobileLayout.titleColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecione o número de Créditos',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF364153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '$credits',
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: ComprarCreditosMobileLayout.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AssetPicture(
                    'public/images/Group 1321315079.svg',
                    width: 26,
                    height: 26,
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 5,
                  activeTrackColor: const Color(0xFFF15C64),
                  inactiveTrackColor: const Color(0xFFD1D5DC),
                  thumbColor: Colors.black,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  'Pack Personalizado: ${credits}€',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: ComprarCreditosMobileLayout.titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFDDE2E8)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '$credits€',
                      style: const TextStyle(
                        fontSize: 38,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: ComprarCreditosMobileLayout.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ComprarAgoraButton(
                    label: buttonLabel,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : onPressed,
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

class _ComprarAgoraButton extends StatelessWidget {
  const _ComprarAgoraButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(150, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
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
