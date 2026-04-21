import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/meus_anuncios/sections/meus_anuncios_professor_content_section.dart';
import 'package:flutter/material.dart';

class MeusAnunciosProfessorMobilePage extends StatelessWidget {
  const MeusAnunciosProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: MeusAnunciosProfessorContentSection(isMobile: true),
    );
  }
}
