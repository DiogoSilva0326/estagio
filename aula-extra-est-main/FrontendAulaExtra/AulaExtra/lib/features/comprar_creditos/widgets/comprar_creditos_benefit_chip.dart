import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_constants.dart';
import 'package:flutter/material.dart';

class ComprarCreditosBenefitChip extends StatelessWidget {
  const ComprarCreditosBenefitChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ComprarCreditosConstants.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: ComprarCreditosConstants.success,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: ComprarCreditosConstants.titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
