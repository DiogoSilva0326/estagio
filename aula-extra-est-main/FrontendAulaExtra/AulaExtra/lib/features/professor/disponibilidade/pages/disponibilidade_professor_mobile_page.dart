import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/disponibilidade/sections/disponibilidade_professor_content_section.dart';
import 'package:flutter/material.dart';

class DisponibilidadeProfessorMobilePage extends StatelessWidget {
  const DisponibilidadeProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: DisponibilidadeProfessorContentSection(isMobile: true),
    );
  }
}
