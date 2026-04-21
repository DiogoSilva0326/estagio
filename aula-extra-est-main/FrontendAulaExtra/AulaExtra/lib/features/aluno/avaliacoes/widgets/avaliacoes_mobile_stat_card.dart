import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:flutter/material.dart';

class AvaliacoesMobileStatCard extends StatelessWidget {
  const AvaliacoesMobileStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.gradient,
    required this.borderColor,
    required this.valueColor,
    required this.labelColor,
    required this.leading,
  });

  final String value;
  final String label;
  final Gradient gradient;
  final Color borderColor;
  final Color valueColor;
  final Color labelColor;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AvaliacoesConstants.mobileTitleStyle.copyWith(
                    fontSize: 20,
                    height: 24 / 20,
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AvaliacoesConstants.mobileMetaStyle.copyWith(
                    fontSize: 11,
                    height: 14 / 11,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
