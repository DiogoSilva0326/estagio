import 'package:aula_extra/core/components/menu_professor/menu_professor.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class ProfessorMenuNav extends StatefulWidget {
  const ProfessorMenuNav({
    super.key,
    this.selectedIndex,
    this.notificationCount,
    this.aulasEstaSemana = 8,
    this.ganhosPendentes = '150€',
    this.alunosAtivos = 12,
    this.onItemTap,
  });

  final int? selectedIndex;
  final int? notificationCount;

  final int aulasEstaSemana;
  final String ganhosPendentes;
  final int alunosAtivos;

  final ValueChanged<int>? onItemTap;

  @override
  State<ProfessorMenuNav> createState() => _ProfessorMenuNavState();
}

class _ProfessorMenuNavState extends State<ProfessorMenuNav> {
  final NotificationsService _notificationsService = NotificationsService();
  late final Future<int> _notificationCountFuture;

  @override
  void initState() {
    super.initState();
    _notificationCountFuture = _loadNotificationCount();
  }

  Future<int> _loadNotificationCount() async {
    final items = await _notificationsService.fetchMyNotifications();
    return items.where((item) => item.unread).length;
  }

  int? _resolveSelectedIndex(BuildContext context) {
    if (widget.selectedIndex != null) return widget.selectedIndex;

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == Routes.professorMeusAlunos) return 0;
    if (routeName == Routes.professorMinhasDisciplinas) return 1;
    if (routeName == Routes.professorCalendario) return 2;
    if (routeName == Routes.professorArquivos) return 4;
    if (routeName == Routes.professorChats) return 5;
    if (routeName == Routes.professorDisponibilidade) return 7;
    if (routeName == Routes.professorPagamentos) return 8;
    if (routeName == Routes.professorAvaliacoes) return 9;
    if (routeName == Routes.professorPerfil) return 10;
    if (routeName == Routes.professorNotificacoes) return 11;
    return null;
  }

  ValueChanged<int> _resolveOnItemTap(BuildContext context) {
    if (widget.onItemTap != null) return widget.onItemTap!;

    return (index) {
      final target = switch (index) {
        0 => Routes.professorMeusAlunos,
        1 => Routes.professorMinhasDisciplinas,
        2 => Routes.professorCalendario,
        4 => Routes.professorArquivos,
        5 => Routes.professorChats,
        7 => Routes.professorDisponibilidade,
        8 => Routes.professorPagamentos,
        9 => Routes.professorAvaliacoes,
        10 => Routes.professorPerfil,
        11 => Routes.professorNotificacoes,
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
    return FutureBuilder<int>(
      future: _notificationCountFuture,
      builder: (context, snapshot) {
        return MenuProfessor(
          selectedIndex: _resolveSelectedIndex(context),
          notificationCount: widget.notificationCount ?? snapshot.data ?? 0,
          aulasEstaSemana: widget.aulasEstaSemana,
          ganhosPendentes: widget.ganhosPendentes,
          alunosAtivos: widget.alunosAtivos,
          onItemTap: _resolveOnItemTap(context),
        );
      },
    );
  }
}
