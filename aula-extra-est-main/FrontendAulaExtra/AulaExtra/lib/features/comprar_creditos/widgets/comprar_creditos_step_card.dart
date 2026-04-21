import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_constants.dart';
import 'package:aula_extra/features/comprar_creditos/constants/comprar_creditos_data.dart';
import 'package:flutter/material.dart';

class ComprarCreditosStepCard extends StatelessWidget {
  const ComprarCreditosStepCard({
    super.key,
    required this.index,
    required this.data,
    this.width,
  });

  final int index;
  final CreditStepData data;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ComprarCreditosConstants.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Alinha os itens verticalmente ao centro da linha
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                  ),
                ),
                child: Icon(data.icon, color: Colors.white, size: 28),
              ),
              // Troquei height por width para dar o espaçamento horizontal
              const SizedBox(width: 22),
              Text(
                '0$index',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: ComprarCreditosConstants.highlight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ComprarCreditosConstants.titleColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: ComprarCreditosConstants.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
