import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_items.dart'; 
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_nav_item.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_stat_row.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherMobileMenuDrawer extends StatefulWidget {
  const TeacherMobileMenuDrawer({
    super.key,
    required this.onClose,
    required this.onLogoutTap,
    this.currentRouteName,
  });

  final VoidCallback onClose;
  final VoidCallback onLogoutTap;
  final String? currentRouteName;

  @override
  State<TeacherMobileMenuDrawer> createState() =>
      _TeacherMobileMenuDrawerState();
}

class _TeacherMobileMenuDrawerState extends State<TeacherMobileMenuDrawer> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();

  late final Future<_TeacherMenuStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_TeacherMenuStats> _loadStats() async {
    final results = await Future.wait<Object?>([
      _calendarService.getProfessorWeek(role: context.read<UserProvider>().role),
      _calendarService.getProfessorUpcoming(limit: 1, role: context.read<UserProvider>().role),
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

  int? _selectedIndex() {
    final routeName = widget.currentRouteName;
    if (routeName == Routes.professorMeusAlunos) return 0;
    if (routeName == Routes.professorMinhasDisciplinas) return 1;
    if (routeName == Routes.professorCalendario) return 2;
    if (routeName == Routes.professorArquivos) return 3;
    if (routeName == Routes.professorChats) return 4;
    if (routeName == Routes.professorPublicarAnuncio) return 5;
    if (routeName == Routes.professorMeusAnuncios) return 6;
    if (routeName == Routes.professorDisponibilidade) return 7;
    if (routeName == Routes.professorPagamentos) return 8;
    if (routeName == Routes.professorAvaliacoes) return 9;
    if (routeName == Routes.professorPerfil) return 10;
    if (routeName == Routes.professorNotificacoes) return 11;
    return null;
  }

  void _onItemTap(BuildContext context, int index) {
    final target = switch (index) {
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

    if (target == null) {
      return;
    }

    widget.onClose();
    if (widget.currentRouteName == target) {
      return;
    }

    Navigator.of(context).pushNamed(target);
  }

  void _showRoleSwitcher(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Mudar Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MenuProfessorColors.textHeading,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _RoleTile(
                  title: 'Modo Aluno',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF6B7280),
                  isActive: userProvider.role == Role.student,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    widget.onClose();
                    userProvider.setRole(Role.student);
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _RoleTile(
                  title: 'Modo Explicador',
                  icon: Icons.menu_book_rounded,
                  color: TeachingRoleConfig.fromRole(Role.teacher).primaryColor,
                  isActive: userProvider.role == Role.teacher,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    widget.onClose();
                    userProvider.setRole(Role.teacher);
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  },
                ),
                _RoleTile(
                  title: 'Modo Tutor',
                  icon: Icons.psychology_alt_rounded,
                  color: TeachingRoleConfig.fromRole(Role.tutor).primaryColor,
                  isActive: userProvider.role == Role.tutor,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    widget.onClose();
                    userProvider.setRole(Role.tutor);
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  },
                ),
                _RoleTile(
                  title: 'Modo Psicólogo',
                  icon: Icons.health_and_safety_rounded,
                  color: TeachingRoleConfig.fromRole(Role.psychologist).primaryColor,
                  isActive: userProvider.role == Role.psychologist,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    widget.onClose();
                    userProvider.setRole(Role.psychologist);
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final items = MenuProfessorItems.all; 

    final nextItemLabel = config.sessionsLabel == 'aulas' ? 'aula' : 'sessão';

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
                      final selectedIndex = _selectedIndex();

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
                          Text(
                            config.menu.menuTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 28 / 22,
                              fontWeight: FontWeight.w600,
                              color: MenuProfessorColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...List.generate(items.length, (index) {
                            final item = items[index];
                            final badgeCount = item.hasBadge
                                ? stats.notificationCount
                                : null;

                            String label = item.label;

                            if (label == 'Meus Alunos') {
                              label = config.studentsLabel;
                            } else if (label == 'Minhas Disciplinas') {
                              label = config.perfil.subjectsSectionTitle;
                            } else if (label == 'Calendário') {
                              label = config.calendarLabel;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: MenuProfessorNavItem(
                                icon: item.icon,
                                label: label,
                                badgeCount: badgeCount,
                                selected: selectedIndex == index,
                                activeColor: config.primaryColor,
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
                                  label: config.menu.statsSessionsLabel,
                                  value: '${stats.aulasEstaSemana}',
                                  valueColor: config.primaryColor,
                                ),
                                const SizedBox(height: 10),
                                MenuProfessorStatRow(
                                  label: 'Tarefas pendentes:',
                                  value: '${stats.tarefasPendentes}',
                                  valueColor: config.primaryColor,
                                ),
                                const SizedBox(height: 10),
                                MenuProfessorStatRow(
                                  label: 'Próxima $nextItemLabel em:',
                                  value: stats.proximaAulaEm,
                                  valueColor: config.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showRoleSwitcher(context, userProvider),
                              icon: const Icon(Icons.swap_horiz_rounded,
                                  size: 20),
                              label: const Text(
                                'MUDAR DE PERFIL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF374151),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? color : const Color(0xFF374151),
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle_rounded, color: color)
          : const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
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