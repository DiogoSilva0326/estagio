import 'package:aula_extra/features/aluno/pagamentos/constants/pagamentos_constants.dart';
import 'package:flutter/material.dart';

class PagamentosMobileIntro extends StatelessWidget {
  const PagamentosMobileIntro({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: PagamentosConstants.mobileTitleStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: PagamentosConstants.mobileSubtitleStyle),
      ],
    );
  }
}
