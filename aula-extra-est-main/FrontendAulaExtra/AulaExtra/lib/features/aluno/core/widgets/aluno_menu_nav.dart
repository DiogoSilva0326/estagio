import 'package:aula_extra/core/components/menu_aluno/menu_aluno.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlunoMenuNav extends StatefulWidget {
  const AlunoMenuNav({
    super.key,
    this.selectedIndex,
    this.notificationCount,
    this.aulasEstaSemana,
    this.tarefasPendentes,
    this.proximaAulaEm,
    this.onItemTap,
  });

  final int? selectedIndex;
  final int? notificationCount;

  final int? aulasEstaSemana;
  final int? tarefasPendentes;
  final String? proximaAulaEm;

  final ValueChanged<int>? onItemTap;

  @override
  State<AlunoMenuNav> createState() => _AlunoMenuNavState();
}

class _AlunoMenuNavState extends State<AlunoMenuNav> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();
  final _paymentsService = PaymentsService();

  late final Future<_AlunoMenuStats> _statsFuture;
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

  @override
  void didUpdateWidget(covariant AlunoMenuNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoadCredits();
  }

  Future<_AlunoMenuStats> _loadStats() async {
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

    return _AlunoMenuStats(
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

  static bool _isActiveLesson(StudentCalendarItemDto item) {
    final status = item.status.trim().toLowerCase();
    if (status.isEmpty) return true;
    return !status.contains('cancel');
  }

  static String _formatNextLesson(StudentCalendarItemDto? item) {
    if (item == null) return 'nenhuma';

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
    if (dayDiff > 1) {
      return 'em $dayDiff dias';
    }

    if (item.startTime.isBefore(now)) {
      return 'já passou';
    }
    if (item.startTime.isAtSameMomentAs(now)) {
      return 'agora';
    }
    return 'em $dayDiff dias';
  }

  int? _resolveSelectedIndex(BuildContext context) {
    if (widget.selectedIndex != null) return widget.selectedIndex;

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == Routes.areasAluno) return 0;
    if (routeName == Routes.meusExplicadores) return 1;
    if (routeName == Routes.meusTutores) return 2;     
    if (routeName == Routes.meusPsicologos) return 3;
    if (routeName == Routes.calendario) return 4;
    if (routeName == Routes.calendarioSemanal) return 4; 
    if (routeName == Routes.arquivos) return 5;
    if (routeName == Routes.chats) return 6;
    if (routeName == Routes.pagamentos) return 7;
    if (routeName == Routes.avaliacoes) return 8;
    if (routeName == Routes.perfilAluno) return 9;
    if (routeName == Routes.notificacoes) return 10;
    return null;
  }

  ValueChanged<int> _resolveOnItemTap(BuildContext context) {
    if (widget.onItemTap != null) return widget.onItemTap!;

    return (index) {
      final target = switch (index) {
        0 => Routes.areasAluno,
        1 => Routes.meusExplicadores,
        2 => Routes.meusTutores,      
        3 => Routes.meusPsicologos,
        4 => Routes.calendario,
        5 => Routes.arquivos,
        6 => Routes.chats,
        7 => Routes.pagamentos,
        8 => Routes.avaliacoes,
        9 => Routes.perfilAluno,
        10 => Routes.notificacoes,
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
    final account = context.watch<UserProvider>().account;

    return FutureBuilder<_AlunoMenuStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const _AlunoMenuStats();

        return MenuAluno(
          selectedIndex: _resolveSelectedIndex(context),
          creditsText: _formatCredits(
            account?.creditsBalance,
            account?.creditsCurrency,
          ),
          notificationCount:
              widget.notificationCount ?? stats.notificationCount,
          aulasEstaSemana: widget.aulasEstaSemana ?? stats.aulasEstaSemana,
          tarefasPendentes: widget.tarefasPendentes ?? stats.tarefasPendentes,
          proximaAulaEm: widget.proximaAulaEm ?? stats.proximaAulaEm,
          onItemTap: _resolveOnItemTap(context),
        );
      },
    );
  }
}

class _AlunoMenuStats {
  const _AlunoMenuStats({
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
