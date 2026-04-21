import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:flutter/material.dart';

class ArquivosMobileStatsCard extends StatelessWidget {
  const ArquivosMobileStatsCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArquivosConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(ArquivosConstants.mobileCardRadius),
        border: Border.all(color: ArquivosConstants.mobileBorderColor),
        boxShadow: ArquivosConstants.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: ArquivosConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 14),
          _StatRow(label: firstLabel, value: firstValue),
          const SizedBox(height: 10),
          _StatRow(label: secondLabel, value: secondValue),
          const SizedBox(height: 10),
          _StatRow(label: thirdLabel, value: thirdValue),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: ArquivosConstants.mobileStatLabelStyle),
        ),
        const SizedBox(width: 12),
        Text(value, style: ArquivosConstants.mobileStatValueStyle),
      ],
    );
  }
}
