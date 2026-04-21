import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ComprarCreditosMobileMetricRow extends StatelessWidget {
  const ComprarCreditosMobileMetricRow({
    super.key,
    required this.value,
    required this.label,
    this.useIcon = false,
  });

  final String value;
  final String label;
  final bool useIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 66,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ComprarCreditosMobileLayout.softHighlight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: useIcon
              ? const Icon(
                  Icons.verified_user_outlined,
                  color: ComprarCreditosMobileLayout.highlight,
                  size: 24,
                )
              : Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: ComprarCreditosMobileLayout.highlight,
                  ),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: ComprarCreditosMobileLayout.subtitleColor,
            ),
          ),
        ),
      ],
    );
  }
}
