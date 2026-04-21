import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class CalendarioMobileIntro extends StatelessWidget {
  const CalendarioMobileIntro({
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
        Text(title, style: CalendarioConstants.mobileTitleStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: CalendarioConstants.mobileSubtitleStyle),
      ],
    );
  }
}
