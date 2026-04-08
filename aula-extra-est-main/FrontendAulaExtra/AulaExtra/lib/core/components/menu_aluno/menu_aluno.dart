import 'package:aula_extra/core/components/menu_aluno/sections/menu_aluno_section.dart';
import 'package:flutter/material.dart';

class MenuAluno extends StatelessWidget {
  const MenuAluno({
    super.key,
    this.selectedIndex,
    this.notificationCount = 0,
    this.aulasEstaSemana = 0,
    this.tarefasPendentes = 0,
    this.proximaAulaEm = 'nenhuma',
    this.onItemTap,
  });

  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final int tarefasPendentes;
  final String proximaAulaEm;

  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return MenuAlunoSection(
      selectedIndex: selectedIndex,
      notificationCount: notificationCount,
      aulasEstaSemana: aulasEstaSemana,
      tarefasPendentes: tarefasPendentes,
      proximaAulaEm: proximaAulaEm,
      onItemTap: onItemTap,
    );
  }
}
