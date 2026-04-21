import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_colors.dart';
import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_items.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_nav_item.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_stat_row.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentMobileMenuDrawer extends StatefulWidget {
  const StudentMobileMenuDrawer({
    super.key,
    required this.onClose,
    required this.onLogoutTap,
  });

  final VoidCallback onClose;
  final VoidCallback onLogoutTap;

  @override
  State<StudentMobileMenuDrawer> createState() =>
      _StudentMobileMenuDrawerState();
}

class _StudentMobileMenuDrawerState extends State<StudentMobileMenuDrawer> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();
  final _paymentsService = PaymentsService();

  late final Future<_StudentMenuStats> _statsFuture;
  bool _isLoadingCredits = false;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoadCredits();
  }

  Future<_StudentMenuStats> _loadStats() async {
    final results = await Future.wait<Object?>([
      _calendarService.getMyWeek(),
      _calendarService.getMyUpcoming(limit: 1),
      _notificationsService.fetchMyNotifications(),
    ]);

    final weeklyLessons = results[0] is List<StudentCalendarItemDto>
        ? (results[0] as List<StudentCalendarItemDto>)
              .where(_isActiveLesson)
              .length
        : 0;
    final upcomingLessons = results[1] is List<StudentCalendarItemDto>
        ? (results[1] as List<StudentCalendarItemDto>)
              .where(_isActiveLesson)
              .toList(growable: false)
        : const <StudentCalendarItemDto>[];
    final notifications = results[2] is List<UserNotificationDto>
        ? (results[2] as List<UserNotificationDto>)
        : const <UserNotificationDto>[];

    return _StudentMenuStats(
      notificationCount: notifications.where((item) => item.unread).length,
      aulasEstaSemana: weeklyLessons,
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

  void _maybeLoadCredits() {
    if (_isLoadingCredits) return;

    final account = context.read<UserProvider>().account;
    if (account == null || account.creditsBalance != null) return;

    _loadCredits();
  }

  Future<void> _loadCredits() async {
    _isLoadingCredits = true;
    try {
      final summary = await _paymentsService.fetchMySummary();
      if (!mounted) return;

      final provider = context.read<UserProvider>();
      provider.setAccount(
        (provider.account ?? const UserAccount()).copyWith(
          creditsBalance: summary.availableCredits,
          creditsCurrency: summary.currency,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      final provider = context.read<UserProvider>();
      provider.setAccount(
        (provider.account ?? const UserAccount()).copyWith(
          creditsBalance: 0,
          creditsCurrency: 'EUR',
        ),
      );
    } finally {
      _isLoadingCredits = false;
    }
  }

  String? _formatCredits(double? balance, String? currency) {
    if (balance == null) return null;

    final symbol = (currency ?? 'EUR').toUpperCase() == 'EUR'
        ? '€'
        : (currency ?? '').trim();
    final fixed = balance
        .toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2)
        .replaceAll('.', ',');
    return symbol.isEmpty ? fixed : '$fixed$symbol';
  }

  String? _creditsBadgeText(double? balance, String? currency) {
    final value = _formatCredits(balance, currency)?.trim();
    if (value == null || value.isEmpty) return null;

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9,]'), '').trim();
    if (digitsOnly.isEmpty) return '$value créditos';
    return '$digitsOnly créditos';
  }

  static bool _isActiveLesson(StudentCalendarItemDto item) {
    final status = item.status.trim().toLowerCase();
    if (status.isEmpty) {
      return true;
    }
    return !status.contains('cancel');
  }

  static String _formatNextLesson(StudentCalendarItemDto? item) {
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
    if (routeName == Routes.areasAluno) return 0;
    if (routeName == Routes.meusExplicadores) return 1;
    if (routeName == Routes.calendario ||
        routeName == Routes.calendarioSemanal) {
      return 2;
    }
    if (routeName == Routes.arquivos) return 3;
    if (routeName == Routes.chats) return 4;
    if (routeName == Routes.pagamentos) return 5;
    if (routeName == Routes.avaliacoes) return 6;
    if (routeName == Routes.perfilAluno) return 7;
    if (routeName == Routes.notificacoes) return 8;
    return null;
  }

  void _onItemTap(BuildContext context, int index) {
    final target = switch (index) {
      0 => Routes.areasAluno,
      1 => Routes.meusExplicadores,
      2 => Routes.calendario,
      3 => Routes.arquivos,
      4 => Routes.chats,
      5 => Routes.pagamentos,
      6 => Routes.avaliacoes,
      7 => Routes.perfilAluno,
      8 => Routes.notificacoes,
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
    final account = context.watch<UserProvider>().account;
    final creditsText = _creditsBadgeText(
      account?.creditsBalance,
      account?.creditsCurrency,
    );

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
                  child: FutureBuilder<_StudentMenuStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data ?? const _StudentMenuStats();
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
                            'Menu do Estudante',
                            style: TextStyle(
                              fontSize: 22,
                              height: 28 / 22,
                              fontWeight: FontWeight.w600,
                              color: MenuAlunoColors.textHeading,
                            ),
                          ),
                          if (creditsText != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFFD6A7),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(15, 23, 42, 0.06),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                creditsText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCA3500),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ...List.generate(MenuAlunoItems.all.length, (index) {
                            final item = MenuAlunoItems.all[index];
                            final badgeCount = item.hasBadge
                                ? stats.notificationCount
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: MenuAlunoNavItem(
                                icon: item.icon,
                                label: item.label,
                                badgeCount: badgeCount,
                                selected: selectedIndex == index,
                                onTap: () => _onItemTap(context, index),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 25),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: MenuAlunoColors.divider),
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
                                    color: MenuAlunoColors.textHeading,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MenuAlunoStatRow(
                                  label: 'Aulas esta semana:',
                                  value: '${stats.aulasEstaSemana}',
                                  valueColor: MenuAlunoColors.accentOrange,
                                ),
                                const SizedBox(height: 12),
                                MenuAlunoStatRow(
                                  label: 'Tarefas pendentes:',
                                  value: '${stats.tarefasPendentes}',
                                  valueColor: MenuAlunoColors.accentOrange,
                                ),
                                const SizedBox(height: 12),
                                MenuAlunoStatRow(
                                  label: 'Próxima aula em:',
                                  value: stats.proximaAulaEm,
                                  valueColor: MenuAlunoColors.accentGreen,
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

class _StudentMenuStats {
  const _StudentMenuStats({
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
