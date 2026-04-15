import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:flutter/material.dart';

class FooterLegalBlock extends StatelessWidget {
  const FooterLegalBlock({
    super.key,
    required this.scale,
    this.items = const [
      'Política de privacidade',
      'Política de cookies',
      'RGPD',
      'Termos e condições',
    ],
  });

  final double scale;
  final List<String> items;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: s(16),
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: FooterColors.textColor,
    );

    final itemStyle = TextStyle(
      fontSize: s(14),
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: FooterColors.textColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: s(6)),
          child: Text('LEGAL', style: titleStyle),
        ),
        for (final item in items) ...[
          SizedBox(height: s(8)),
          Text(item, style: itemStyle),
        ],
      ],
    );
  }
}