import 'package:aula_extra/core/components/menu_professor/sections/menu_professor_section.dart';
import 'package:flutter/material.dart';

class MenuProfessor extends StatelessWidget {
  const MenuProfessor({
    super.key,
    this.selectedIndex,
    this.notificationCount = 0,
    this.aulasEstaSemana = 8,
    this.ganhosPendentes = '150€',
    this.alunosAtivos = 12,
    this.onItemTap,
  });

  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final String ganhosPendentes;
  final int alunosAtivos;

  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return MenuProfessorSection(
      selectedIndex: selectedIndex,
      notificationCount: notificationCount,
      aulasEstaSemana: aulasEstaSemana,
      ganhosPendentes: ganhosPendentes,
      alunosAtivos: alunosAtivos,
      onItemTap: onItemTap,
    );
  }
}
