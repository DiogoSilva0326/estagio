import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/meus_alunos/sections/meus_alunos_professor_content_section.dart';
import 'package:flutter/material.dart';

class MeusAlunosProfessorMobilePage extends StatelessWidget {
  const MeusAlunosProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      backgroundColor: Color(0xFFF9FAFB),
      child: MeusAlunosProfessorContentSection(isMobile: true),
    );
  }
}
