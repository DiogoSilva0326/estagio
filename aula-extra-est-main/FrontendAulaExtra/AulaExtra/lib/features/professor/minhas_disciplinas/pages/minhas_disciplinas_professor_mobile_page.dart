import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/sections/minhas_disciplinas_professor_content_section.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorMobilePage extends StatelessWidget {
  const MinhasDisciplinasProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      backgroundColor: Color(0xFFF9F9F9),
      child: MinhasDisciplinasProfessorContentSection(isMobile: true),
    );
  }
}
