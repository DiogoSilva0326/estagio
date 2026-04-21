import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/notificacoes/sections/notificacoes_professor_content_section.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorMobilePage extends StatelessWidget {
  const NotificacoesProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: NotificacoesProfessorContentSection(isMobile: true),
    );
  }
}
