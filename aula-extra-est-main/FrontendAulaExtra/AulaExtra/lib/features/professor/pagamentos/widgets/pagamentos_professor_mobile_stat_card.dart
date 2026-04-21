import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorMobileStatCard extends StatelessWidget {
  const PagamentosProfessorMobileStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.valueColor,
    required this.labelColor,
    required this.gradient,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color borderColor;
  final Color valueColor;
  final Color labelColor;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          PagamentosProfessorLayout.mobileStatCardRadius,
        ),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: valueColor),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 22 / 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 16 / 11,
            ),
          ),
        ],
      ),
    );
  }
}
