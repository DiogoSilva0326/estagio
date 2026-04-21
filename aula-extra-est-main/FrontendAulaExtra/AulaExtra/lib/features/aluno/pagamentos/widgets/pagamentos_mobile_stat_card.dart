import 'package:flutter/material.dart';

class PagamentosMobileStatCard extends StatelessWidget {
  const PagamentosMobileStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.borderColor,
    required this.valueColor,
    required this.labelColor,
    required this.gradient,
  });

  final String value;
  final String label;
  final Color borderColor;
  final Color valueColor;
  final Color labelColor;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 24 / 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: labelColor,
              height: 16 / 11,
            ),
          ),
        ],
      ),
    );
  }
}
