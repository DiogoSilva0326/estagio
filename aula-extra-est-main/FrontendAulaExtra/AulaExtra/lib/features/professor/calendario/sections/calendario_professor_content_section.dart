import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_layout.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_mock_data.dart';
import 'package:aula_extra/features/professor/calendario/widgets/aula_card.dart';
import 'package:aula_extra/features/professor/calendario/widgets/calendario_tabs.dart';
import 'package:aula_extra/features/professor/calendario/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';

class CalendarioProfessorContentSection extends StatefulWidget {
  const CalendarioProfessorContentSection({
    super.key,
  });

  @override
  State<CalendarioProfessorContentSection> createState() => _CalendarioProfessorContentSectionState();
}

class _CalendarioProfessorContentSectionState extends State<CalendarioProfessorContentSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: CalendarioProfessorColors.title,
      fontWeight: FontWeight.w700,
      fontSize: CalendarioProfessorLayout.titleFontSize,
      height: CalendarioProfessorLayout.titleLineHeight / CalendarioProfessorLayout.titleFontSize,
    );

    return Container(
      color: CalendarioProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: CalendarioProfessorLayout.pageLeftPadding,
            right: CalendarioProfessorLayout.pageRightPadding,
            top: CalendarioProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const ProfessorMenuNav(selectedIndex: 1),
              const SizedBox(width: CalendarioProfessorLayout.sidebarContentGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: CalendarioProfessorLayout.contentPadding,
                    left: CalendarioProfessorLayout.contentPadding,
                    right: CalendarioProfessorLayout.contentPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: CalendarioProfessorLayout.titleLineHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Calendário', style: titleStyle),
                            _AddHorarioButton(onTap: () {}),
                          ],
                        ),
                      ),
                      const SizedBox(height: CalendarioProfessorLayout.contentGap),
                      CalendarioTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (index) => setState(() => _selectedTab = index),
                      ),
                      const SizedBox(height: 37.813),
                      if (_selectedTab == 0)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: CalendarioProfessorMockData.proximasAulas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: CalendarioProfessorLayout.listGap),
                          itemBuilder: (context, index) {
                            final aula = CalendarioProfessorMockData.proximasAulas[index];
                            return AulaCard(
                              data: aula,
                              onEnterTap: () {},
                              onCancelTap: () {},
                            );
                          },
                        )
                      else
                        const SizedBox.shrink(),
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

class _AddHorarioButton extends StatelessWidget {
  const _AddHorarioButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CalendarioProfessorLayout.addButtonWidth,
      height: CalendarioProfessorLayout.addButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CalendarioProfessorLayout.addButtonRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CalendarioProfessorColors.addGradientTop,
              CalendarioProfessorColors.addGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CalendarioProfessorLayout.addButtonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: CalendarioProfessorLayout.addButtonIconSize,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  'Adicionar Horário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: CalendarioProfessorLayout.addButtonFontSize,
                    fontWeight: FontWeight.w500,
                    height: CalendarioProfessorLayout.addButtonLineHeight /
                        CalendarioProfessorLayout.addButtonFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
