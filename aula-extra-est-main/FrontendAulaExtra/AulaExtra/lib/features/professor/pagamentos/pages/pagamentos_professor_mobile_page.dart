import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/pagamentos/sections/pagamentos_professor_content_section.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorMobilePage extends StatelessWidget {
  const PagamentosProfessorMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessorMobilePageScaffold(
      child: PagamentosProfessorContentSection(isMobile: true),
    );
  }
}
