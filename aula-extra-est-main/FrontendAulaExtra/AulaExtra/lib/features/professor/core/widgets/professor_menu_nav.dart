import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/components/menu_professor/sections/menu_professor_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class ProfessorMenuNav extends StatefulWidget {
  const ProfessorMenuNav({
    super.key,
    this.selectedIndex,
    this.notificationCount,
    this.aulasEstaSemana,
    this.ganhosPendentes,
    this.alunosAtivos,
  });

  final int? selectedIndex;
  final int? notificationCount;
  final int? aulasEstaSemana;
  final String? ganhosPendentes;
  final int? alunosAtivos;

  @override
  State<ProfessorMenuNav> createState() => _ProfessorMenuNavState();
}

class _ProfessorMenuNavState extends State<ProfessorMenuNav> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();

  late final Future<_TeacherMenuStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_TeacherMenuStats> _loadStats() async {
    final hasProvidedStats = widget.aulasEstaSemana != null &&
        widget.alunosAtivos != null &&
        widget.notificationCount != null;

    if (hasProvidedStats) {
      return _TeacherMenuStats(
        notificationCount: widget.notificationCount!,
        aulasEstaSemana: widget.aulasEstaSemana!,
        tarefasPendentes: 0,
      );
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final results = await Future.wait([
        _calendarService.getProfessorWeek(role: userProvider.role),
        _notificationsService.fetchMyNotifications(),
      ]);

      final weekLessons = results[0] is List<ProfessorCalendarItemDto>
          ? (results[0] as List<ProfessorCalendarItemDto>)
              .where((item) {
                final status = item.status.trim().toLowerCase();
                return status.isEmpty || !status.contains('cancel');
              })
              .length
          : 0;

      final notifications = results[1] is List<dynamic>
          ? (results[1] as List<dynamic>)
          : const [];

      return _TeacherMenuStats(
        notificationCount: notifications.where((item) => item.unread).length,
        aulasEstaSemana: weekLessons,
        tarefasPendentes: 0, 
      );
    } catch (_) {
      return const _TeacherMenuStats();
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == widget.selectedIndex) return;

    final targetRoute = switch (index) {
      0 => Routes.professorMeusAlunos,
      1 => Routes.professorMinhasDisciplinas,
      2 => Routes.professorCalendario,
      3 => Routes.professorArquivos,
      4 => Routes.professorChats,
      5 => Routes.professorPublicarAnuncio,
      6 => Routes.professorMeusAnuncios,
      7 => Routes.professorDisponibilidade,
      8 => Routes.professorPagamentos,
      9 => Routes.professorAvaliacoes,
      10 => Routes.professorPerfil,
      11 => Routes.professorNotificacoes,
      _ => null,
    };

    if (targetRoute != null) {
      Navigator.of(context).pushNamed(targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    return FutureBuilder<_TeacherMenuStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            _TeacherMenuStats(
              notificationCount: widget.notificationCount ?? 0,
              aulasEstaSemana: widget.aulasEstaSemana ?? 0,
            );

        return MenuProfessorSection(
          config: config,
          selectedIndex: widget.selectedIndex,
          notificationCount: stats.notificationCount,
          aulasEstaSemana: stats.aulasEstaSemana,
          ganhosPendentes: widget.ganhosPendentes ?? '0€',
          alunosAtivos: widget.alunosAtivos ?? 0,
          onItemTap: (index) => _handleNavigation(context, index),
        );
      },
    );
  }
}

class _TeacherMenuStats {
  const _TeacherMenuStats({
    this.notificationCount = 0,
    this.aulasEstaSemana = 0,
    this.tarefasPendentes = 0,
  });

  final int notificationCount;
  final int aulasEstaSemana;
  final int tarefasPendentes;
}