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
        color: selected ? CalendarioProfessorColors.tabSelectedText : const Color(0xFF667085),
        fontSize: CalendarioProfessorLayout.tabFontSize,
        fontWeight: FontWeight.w500,
      );
    }

    Widget tab({required int index, required String label}) {
      final isSelected = selectedIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(index),
          borderRadius: BorderRadius.circular(CalendarioProfessorLayout.tabRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: CalendarioProfessorLayout.tabHeight,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(CalendarioProfessorLayout.tabRadius),
              boxShadow: isSelected
                  ? [const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), offset: Offset(0, 2), blurRadius: 4)]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(label, style: tabTextStyle(isSelected), maxLines: 1),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: CalendarioProfessorLayout.tabsHeight,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: CalendarioProfessorColors.tabsBackground,
        borderRadius: BorderRadius.circular(CalendarioProfessorLayout.tabsRadius),
      ),
      child: Row(
        children: [
          tab(index: 0, label: 'Próximas Aulas'),
          tab(index: 1, label: 'Agenda Real'),
        ],
      ),
    );
  }
}