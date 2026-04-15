import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:flutter/material.dart';

class FooterNewsletterBlock extends StatelessWidget {
  const FooterNewsletterBlock({
    super.key,
    required this.scale,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  });

  final double scale;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          'NEWSLETTER',
          textAlign: textAlign,
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w700,
            color: FooterColors.textColor,
          ),
        ),
        SizedBox(height: s(6)),
        Text(
          const [
            'Subscreve para',
            'receber atualizações',
            'sobre novos explicadores',
            'e ofertas especiais',
          ].join('\n'),
          textAlign: textAlign,
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w400,
            color: FooterColors.textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}