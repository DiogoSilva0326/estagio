import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/perfil/sections/perfil_professor_content_section.dart';
import 'package:flutter/material.dart';

class PerfilProfessorMobilePage extends StatelessWidget {
  const PerfilProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: PerfilProfessorContentSection(isMobile: true),
    );
  }
}
