import 'package:aula_extra/core/components/menu_aluno/menu_aluno.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class AlunoMenuNav extends StatelessWidget {
  const AlunoMenuNav({
    super.key,
    this.selectedIndex,
    this.notificationCount = 0,
    this.aulasEstaSemana = 4,
    this.tarefasPendentes = 2,
    this.proximaAulaEm = '5 minutos',
    this.onItemTap,
  });

  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final int tarefasPendentes;
  final String proximaAulaEm;

  final ValueChanged<int>? onItemTap;

  int? _resolveSelectedIndex(BuildContext context) {
    if (selectedIndex != null) return selectedIndex;

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == Routes.areasAluno) return 0;
    if (routeName == Routes.meusExplicadores) return 1;
    if (routeName == Routes.calendario) return 2;
    if (routeName == Routes.calendarioSemanal) return 2;
    if (routeName == Routes.arquivos) return 4;
    if (routeName == Routes.chats) return 5;
    if (routeName == Routes.pagamentos) return 6;
    if (routeName == Routes.avaliacoes) return 7;
    if (routeName == Routes.perfilAluno) return 8;
    if (routeName == Routes.notificacoes) return 9;
    return null;
  }

  ValueChanged<int> _resolveOnItemTap(BuildContext context) {
    if (onItemTap != null) return onItemTap!;

    return (index) {
      final target = switch (index) {
        0 => Routes.areasAluno,
        1 => Routes.meusExplicadores,
        2 => Routes.calendario,
        4 => Routes.arquivos,
        5 => Routes.chats,
        6 => Routes.pagamentos,
        7 => Routes.avaliacoes,
        8 => Routes.perfilAluno,
        9 => Routes.notificacoes,
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
    return MenuAluno(
      selectedIndex: _resolveSelectedIndex(context),
      notificationCount: notificationCount,
      aulasEstaSemana: aulasEstaSemana,
      tarefasPendentes: tarefasPendentes,
      proximaAulaEm: proximaAulaEm,
      onItemTap: _resolveOnItemTap(context),
    );
  }
}
