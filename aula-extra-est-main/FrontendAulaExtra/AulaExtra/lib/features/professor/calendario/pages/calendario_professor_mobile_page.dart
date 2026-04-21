import 'package:aula_extra/features/professor/calendario/sections/calendario_professor_content_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:flutter/material.dart';

class CalendarioProfessorMobilePage extends StatelessWidget {
  const CalendarioProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      backgroundColor: Color(0xFFF9FAFB),
      footerTopSpacing: 8,
      child: CalendarioProfessorContentSection(isMobile: true),
    );
  }
}
