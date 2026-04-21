import 'package:flutter/material.dart';

class ArquivosProfessorMobileStatsCard extends StatelessWidget {
  const ArquivosProfessorMobileStatsCard({
    super.key,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
    required this.thirdLabel,
    required this.thirdValue,
  });

  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;
  final String thirdLabel;
  final String thirdValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.69),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 27 / 18,
            ),
          ),
          const SizedBox(height: 16),
          _StatsRow(
            label: firstLabel,
            value: firstValue,
            valueColor: const Color(0xFFFF6900),
          ),
          const SizedBox(height: 12),
          _StatsRow(
            label: secondLabel,
            value: secondValue,
            valueColor: const Color(0xFFFF6900),
          ),
          const SizedBox(height: 12),
          _StatsRow(
            label: thirdLabel,
            value: thirdValue,
            valueColor: const Color(0xFF00A63E),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 20 / 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
