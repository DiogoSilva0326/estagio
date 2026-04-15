import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_nav_item.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_stat_row.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class TeacherMobileMenuDrawer extends StatefulWidget {
  const TeacherMobileMenuDrawer({
    super.key,
    required this.onClose,
    required this.onLogoutTap,
  });

  final VoidCallback onClose;
  final VoidCallback onLogoutTap;

  @override
  State<TeacherMobileMenuDrawer> createState() =>
      _TeacherMobileMenuDrawerState();
}

class _TeacherMobileMenuDrawerState extends State<TeacherMobileMenuDrawer> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();

  late final Future<_TeacherMenuStats> _statsFuture;

  static const _items = <_TeacherMenuItem>[
    _TeacherMenuItem('Meus Alunos', Icons.groups_rounded),
    _TeacherMenuItem('Calendário', Icons.calendar_month_rounded),
    _TeacherMenuItem('Arquivos', Icons.description_outlined),
    _TeacherMenuItem('Chats', Icons.chat_bubble_outline_rounded),
    _TeacherMenuItem('Publicar Anúncio', Icons.campaign_rounded),
    _TeacherMenuItem('Os meus anúncios', Icons.view_agenda_rounded),
    _TeacherMenuItem('Disponibilidade', Icons.schedule_rounded),
    _TeacherMenuItem('Pagamentos', Icons.payments_rounded),
    _TeacherMenuItem('Disciplinas', Icons.menu_book_rounded),
    _TeacherMenuItem('Avaliações', Icons.star_rounded),
    _TeacherMenuItem('Perfil', Icons.person_rounded),
    _TeacherMenuItem(
      'Notificações',
      Icons.notifications_rounded,
      hasBadge: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_TeacherMenuStats> _loadStats() async {
    final results = await Future.wait<Object?>([
      _calendarService.getProfessorWeek(),
      _calendarService.getProfessorUpcoming(limit: 1),
      _notificationsService.fetchMyNotifications(),
    ]);

    final weekLessons = results[0] is List<ProfessorCalendarItemDto>
        ? (results[0] as List<ProfessorCalendarItemDto>)
              .where(_isActiveLesson)
              .length
        : 0;
    final upcomingLessons = results[1] is List<ProfessorCalendarItemDto>
        ? (results[1] as List<ProfessorCalendarItemDto>)
              .where(_isActiveLesson)
              .toList(growable: false)
        : const <ProfessorCalendarItemDto>[];
    final notifications = results[2] is List<UserNotificationDto>
        ? (results[2] as List<UserNotificationDto>)
        : const <UserNotificationDto>[];

    return _TeacherMenuStats(
      notificationCount: notifications.where((item) => item.unread).length,
      aulasEstaSemana: weekLessons,
      tarefasPendentes: notifications
          .where(
            (item) => item.unread && item.kind == UserNotificationKind.tarefa,
          )
          .length,
      proximaAulaEm: _formatNextLesson(
        upcomingLessons.isEmpty ? null : upcomingLessons.first,
      ),
    );
  }

  static bool _isActiveLesson(ProfessorCalendarItemDto item) {
    final status = item.status.trim().toLowerCase();
    if (status.isEmpty) {
      return true;
    }
    return !status.contains('cancel');
  }

  static String _formatNextLesson(ProfessorCalendarItemDto? item) {
    if (item == null) {
      return 'nenhuma';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(
      item.startTime.year,
      item.startTime.month,
      item.startTime.day,
    );
    final dayDiff = targetDay.difference(today).inDays;
    final timeLabel =
        '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}';

    if (dayDiff < 0) {
      return 'já passou';
    }
    if (dayDiff == 0) {
      final diff = item.startTime.difference(now);
      if (diff.inMinutes.abs() < 1) {
        return 'agora';
      }
      if (diff.inMinutes < 60) {
        return 'em ${diff.inMinutes} min';
      }
      return 'hoje $timeLabel';
    }
    if (dayDiff == 1) {
      return 'amanhã $timeLabel';
    }
    return 'em $dayDiff dias';
  }

  int? _selectedIndex(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == Routes.professorMeusAlunos) return 0;
    if (routeName == Routes.professorCalendario) return 1;
    if (routeName == Routes.professorArquivos) return 2;
    if (routeName == Routes.professorChats) return 3;
    if (routeName == Routes.professorPublicarAnuncio) return 4;
    if (routeName == Routes.professorMeusAnuncios) return 5;
    if (routeName == Routes.professorDisponibilidade) return 6;
    if (routeName == Routes.professorPagamentos) return 7;
    if (routeName == Routes.professorMinhasDisciplinas) return 8;
    if (routeName == Routes.professorAvaliacoes) return 9;
    if (routeName == Routes.professorPerfil) return 10;
    if (routeName == Routes.professorNotificacoes) return 11;
    return null;
  }

  void _onItemTap(BuildContext context, int index) {
    final target = switch (index) {
      0 => Routes.professorMeusAlunos,
      1 => Routes.professorCalendario,
      2 => Routes.professorArquivos,
      3 => Routes.professorChats,
      4 => Routes.professorPublicarAnuncio,
      5 => Routes.professorMeusAnuncios,
      6 => Routes.professorDisponibilidade,
      7 => Routes.professorPagamentos,
      8 => Routes.professorMinhasDisciplinas,
      9 => Routes.professorAvaliacoes,
      10 => Routes.professorPerfil,
      11 => Routes.professorNotificacoes,
      _ => null,
    };

    if (target == null) {
      return;
    }

    final current = ModalRoute.of(context)?.settings.name;
    widget.onClose();
    if (current == target) {
      return;
    }

    Navigator.of(context).pushNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(19),
        bottomLeft: Radius.circular(19),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: Color(0xFFE5E7EB), width: 0.7),
          ),
        ),
        child: SafeArea(
          left: false,
          child: SizedBox(
            width: 308,
            height: double.infinity,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: FutureBuilder<_TeacherMenuStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? const _TeacherMenuStats();
                      final selectedIndex = _selectedIndex(context);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: widget.onClose,
                              borderRadius: BorderRadius.circular(16),
                              child: const SizedBox(
                                width: 32,
                                height: 32,
                                child: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Color(0xFF364153),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Menu do Explicador',
                            style: TextStyle(
                              fontSize: 22,
                              height: 28 / 22,
                              fontWeight: FontWeight.w600,
                              color: MenuProfessorColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...List.generate(_items.length, (index) {
                            final item = _items[index];
                            final badgeCount = item.hasBadge
                                ? stats.notificationCount
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: MenuProfessorNavItem(
                                icon: item.icon,
                                label: item.label,
                                badgeCount: badgeCount,
                                selected: selectedIndex == index,
                                onTap: () => _onItemTap(context, index),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: MenuProfessorColors.divider,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estatísticas',
                                  style: TextStyle(
                                    fontSize: 22,
                                    height: 20 / 22,
                                    fontWeight: FontWeight.w600,
                                    color: MenuProfessorColors.textHeading,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MenuProfessorStatRow(
                                  label: 'Aulas esta semana:',
                                  value: '${stats.aulasEstaSemana}',
                                  valueColor: MenuProfessorColors.accentOrange,
                                ),
                                const SizedBox(height: 10),
                                MenuProfessorStatRow(
                                  label: 'Tarefas pendentes:',
                                  value: '${stats.tarefasPendentes}',
                                  valueColor: MenuProfessorColors.accentOrange,
                                ),
                                const SizedBox(height: 10),
                                MenuProfessorStatRow(
                                  label: 'Próxima aula em:',
                                  value: stats.proximaAulaEm,
                                  valueColor: MenuProfessorColors.accentGreen,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: widget.onLogoutTap,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFF2B8B5),
                                  width: 0.7,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'TERMINAR SESSÃO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD14343),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherMenuItem {
  const _TeacherMenuItem(this.label, this.icon, {this.hasBadge = false});

  final String label;
  final IconData icon;
  final bool hasBadge;
}

class _TeacherMenuStats {
  const _TeacherMenuStats({
    this.notificationCount = 0,
    this.aulasEstaSemana = 0,
    this.tarefasPendentes = 0,
    this.proximaAulaEm = 'nenhuma',
  });

  final int notificationCount;
  final int aulasEstaSemana;
  final int tarefasPendentes;
  final String proximaAulaEm;
}
