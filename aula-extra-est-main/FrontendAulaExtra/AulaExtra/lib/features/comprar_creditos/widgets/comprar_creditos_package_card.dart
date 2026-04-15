import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:flutter/material.dart';

class ComprarCreditosPackageCard extends StatelessWidget {
  const ComprarCreditosPackageCard({
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
    final badgeColor = data.badgeColor;

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
        clipBehavior: Clip.none,
        children: [
          if (data.badge != null)
            Positioned(
              top: -50,
              right: -16,
              child: Container(
                width: 177,
                height: 50,
                decoration: BoxDecoration(
                  color: badgeColor,
                  gradient: badgeColor == null
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        )
                      : null,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20.057),
                    bottomLeft: Radius.circular(27),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  data.badge!,
                  style: const TextStyle(
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
                  const SizedBox(width: 13),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 29.179,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E2939),
                              letterSpacing: 0.3847,
                              height: 35.015 / 29.179,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${data.credits} Créditos',
                            style: const TextStyle(
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
              const SizedBox(height: 26),
              Text(
                data.caption,
                style: const TextStyle(
                  fontSize: 17.872,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF364153),
                  letterSpacing: -0.192,
                  height: 25.532 / 17.872,
                ),
              ),
              const SizedBox(height: 18),
              ...data.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    feature.startsWith('Preço unitário') ? feature : '✓ $feature',
                    style: const TextStyle(
                      fontSize: 17.872,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF364153),
                      letterSpacing: -0.192,
                      height: 25.532 / 17.872,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Divider(height: 1, color: Color(0xFFDDE2E8)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    data.priceLabel,
                    style: const TextStyle(
                      fontSize: 50.219,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFC9039),
                      letterSpacing: 0.6621,
                      height: 60.262 / 50.219,
                    ),
                  ),
                  const Spacer(),
                  _ComprarAgoraButton(
                    label: buttonLabel,
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
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
        ),
        borderRadius: BorderRadius.circular(12.766),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(172, 54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.766),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20.426,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: -0.3989,
            height: 30.638 / 20.426,
          ),
        ),
      ),
    );
  }
}