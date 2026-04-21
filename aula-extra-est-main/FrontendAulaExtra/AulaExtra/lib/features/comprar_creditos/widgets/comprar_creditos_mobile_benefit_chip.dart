import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ComprarCreditosMobileBenefitChip extends StatelessWidget {
  const ComprarCreditosMobileBenefitChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ComprarCreditosMobileLayout.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: ComprarCreditosMobileLayout.success,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF364153),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
