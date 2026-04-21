import 'package:aula_extra/features/professor/arquivos/sections/arquivos_professor_content_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:flutter/material.dart';

class ArquivosProfessorMobilePage extends StatelessWidget {
  const ArquivosProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      backgroundColor: Color(0xFFF9FAFB),
      footerTopSpacing: 8,
      child: ArquivosProfessorContentSection(isMobile: true),
    );
  }
}
