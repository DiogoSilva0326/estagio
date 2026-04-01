import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_colors.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_layout.dart';
import 'package:aula_extra/features/professor/disponibilidade/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';
import 'package:aula_extra/features/professor/disponibilidade/widgets/horario_padrao_professor.dart';

class DisponibilidadeProfessorContentSection extends StatelessWidget {
  const DisponibilidadeProfessorContentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: DisponibilidadeProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: DisponibilidadeProfessorLayout.titleFontSize,
      height: DisponibilidadeProfessorLayout.titleLineHeight / DisponibilidadeProfessorLayout.titleFontSize,
    );

    return Container(
      color: DisponibilidadeProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: DisponibilidadeProfessorLayout.pageLeftPadding,
            right: DisponibilidadeProfessorLayout.pageRightPadding,
            top: DisponibilidadeProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 6), 
              
              const SizedBox(width: DisponibilidadeProfessorLayout.sidebarContentGap),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: DisponibilidadeProfessorLayout.contentPadding,
                    left: DisponibilidadeProfessorLayout.contentPadding,
                    right: DisponibilidadeProfessorLayout.contentPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: DisponibilidadeProfessorLayout.titleLineHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Disponibilidade', style: titleStyle),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.889),
                      const HorarioPadraoProfessor(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}