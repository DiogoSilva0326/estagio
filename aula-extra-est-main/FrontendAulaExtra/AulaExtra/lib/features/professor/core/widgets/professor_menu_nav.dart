import 'package:aula_extra/core/components/menu_professor/menu_professor.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class ProfessorMenuNav extends StatelessWidget {
  const ProfessorMenuNav({
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

  int? _resolveSelectedIndex(BuildContext context) {
    if (selectedIndex != null) return selectedIndex;

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == Routes.professorMeusAlunos) return 0;
    if (routeName == Routes.professorCalendario) return 1;
    if (routeName == Routes.professorArquivos) return 3;
    if (routeName == Routes.professorChats) return 4;
    if (routeName == Routes.professorDisponibilidade) return 6;
    if (routeName == Routes.professorPagamentos) return 7;
    if (routeName == Routes.professorAvaliacoes) return 8;
    if (routeName == Routes.professorPerfil) return 9;
    if (routeName == Routes.professorNotificacoes) return 10;
    return null;
  }

  ValueChanged<int> _resolveOnItemTap(BuildContext context) {
    if (onItemTap != null) return onItemTap!;

    return (index) {
      final target = switch (index) {
        0 => Routes.professorMeusAlunos,
        1 => Routes.professorCalendario,
        3 => Routes.professorArquivos,
        4 => Routes.professorChats,
        6 => Routes.professorDisponibilidade,
        7 => Routes.professorPagamentos,
        8 => Routes.professorAvaliacoes,
        9 => Routes.professorPerfil,
        10 => Routes.professorNotificacoes,
        _ => null,
      };

      if (target == null) return;

      final current = ModalRoute.of(context)?.settings.name;
      if (current == target) return;

      Navigator.of(context).pushNamed(target);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MenuProfessor(
      selectedIndex: _resolveSelectedIndex(context),
      notificationCount: notificationCount,
      aulasEstaSemana: aulasEstaSemana,
      ganhosPendentes: ganhosPendentes,
      alunosAtivos: alunosAtivos,
      onItemTap: _resolveOnItemTap(context),
    );
  }
}
