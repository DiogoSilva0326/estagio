import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/avaliacoes/sections/avaliacoes_professor_content_section.dart';
import 'package:flutter/material.dart';

class AvaliacoesProfessorMobilePage extends StatelessWidget {
  const AvaliacoesProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: AvaliacoesProfessorContentSection(isMobile: true),
    );
  }
}
