import 'package:flutter/material.dart';

class PagamentosStatCard extends StatelessWidget {
  const PagamentosStatCard({
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
      height: 150.632,
      padding: const EdgeInsets.fromLTRB(34.235, 34.235, 34.235, 1.369),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(21.91),
        border: Border.all(color: borderColor, width: 1.369),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 41.081,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 49.298 / 41.081,
            ),
          ),
          const SizedBox(height: 5.478),
          Text(
            label,
            style: TextStyle(
              fontSize: 19.171,
              fontWeight: FontWeight.w400,
              color: labelColor,
              height: 27.388 / 19.171,
            ),
          ),
        ],
      ),
    );
  }
}
