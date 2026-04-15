import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_layout.dart';
import 'package:flutter/material.dart';

class CalendarioTabs extends StatelessWidget {
  const CalendarioTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    TextStyle tabTextStyle(bool selected) {
      return TextStyle(
        color: selected
            ? CalendarioProfessorColors.tabSelectedText
            : CalendarioProfessorColors.tabSelectedText,
        fontSize: CalendarioProfessorLayout.tabFontSize,
        fontWeight: FontWeight.w500,
        height:
            CalendarioProfessorLayout.tabLineHeight /
            CalendarioProfessorLayout.tabFontSize,
      );
    }

    Widget tab({required int index, required String label}) {
      final isSelected = selectedIndex == index;

      return Expanded(
        child: InkWell(
          onTap: () => onChanged(index),
          borderRadius: BorderRadius.circular(
            CalendarioProfessorLayout.tabRadius,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: CalendarioProfessorLayout.tabHeight,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(
                CalendarioProfessorLayout.tabRadius,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                        offset: Offset(0, 1.182),
                        blurRadius: 3.545,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                        offset: Offset(0, 1.182),
                        blurRadius: 2.363,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: CalendarioProfessorLayout.tabPaddingH,
              vertical: CalendarioProfessorLayout.tabPaddingV,
            ),
            child: Text(
              label,
              style: tabTextStyle(isSelected),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: CalendarioProfessorLayout.tabsWidth,
      height: CalendarioProfessorLayout.tabsHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CalendarioProfessorColors.tabsBackground,
          borderRadius: BorderRadius.circular(
            CalendarioProfessorLayout.tabsRadius,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              tab(index: 0, label: 'Próximas Aulas'),
              tab(index: 1, label: 'Calendário Semanal'),
            ],
          ),
        ),
      ),
    );
  }
}
