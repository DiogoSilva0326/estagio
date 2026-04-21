import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ComprarCreditosMobileStepCard extends StatelessWidget {
  const ComprarCreditosMobileStepCard({
    super.key,
    required this.index,
    required this.data,
  });

  final int index;
  final CreditStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ComprarCreditosMobileLayout.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
              ),
            ),
            child: Icon(data.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            '0$index',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: ComprarCreditosMobileLayout.mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: ComprarCreditosMobileLayout.titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: ComprarCreditosMobileLayout.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
