import 'dart:async';

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/lesson_classroom/lesson_classroom_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/features/aluno/calendario/state/student_calendar_refresh_bus.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mobile_cta_button.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mobile_intro.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mode_tabs.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_upcoming_lesson_card.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/pending_lesson_review_dialog.dart';
import 'package:aula_extra/features/classroom/pages/live_classroom_page.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CalendarioContentSection extends StatelessWidget {
  const CalendarioContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    void onWeeklyTap() {
      Navigator.of(context).pushReplacementNamed(Routes.calendarioSemanal);
    }

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CalendarioConstants.mobileHorizontalPadding,
          vertical: CalendarioConstants.mobileVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CalendarioMobileIntro(
              title: 'Calendário',
              subtitle:
                  'Escolhe uma área ou disciplina específica para encontrar os teus próximos apoios.',
            ),
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            CalendarioModeTabs(
              activeMode: CalendarioMode.upcoming,
              onUpcomingTap: () {},
              onWeeklyTap: onWeeklyTap,
              isMobile: true,
            ),
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            const _UpcomingLessonsList(isMobile: true),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalendarioConstants.horizontalPadding,
        vertical: CalendarioConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(),
          const SizedBox(width: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Calendário',
                    style: CalendarioConstants.titleStyle,
                  ),
                  const SizedBox(height: 11.202),
                  const Text(
                    'Organize os seus apoios e compromissos',
                    style: CalendarioConstants.subtitleStyle,
                  ),
                  const SizedBox(height: 33.607),
                  CalendarioModeTabs(
                    activeMode: CalendarioMode.upcoming,
                    onUpcomingTap: () {},
                    onWeeklyTap: onWeeklyTap,
                    isMobile: false,
                  ),
                  const SizedBox(height: 22.404),
                  const _UpcomingLessonsList(isMobile: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PrimaryActionStyle { enterClass, viewDetails }

enum _LateCancellationAction { cancelWithoutJustification, justify }

class _UpcomingLessonsList extends StatefulWidget {
  const _UpcomingLessonsList({required this.isMobile});

  final bool isMobile;

  @override
  State<_UpcomingLessonsList> createState() => _UpcomingLessonsListState();
}

class _UpcomingLessonsListState extends State<_UpcomingLessonsList> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  final LessonClassroomService _lessonClassroomService =
      LessonClassroomService();
  final NotificationsService _notificationsService = NotificationsService();
  final UsersService _usersService = UsersService();
  late Future<List<StudentCalendarItemDto>> _future;
  int _limit = 4;
  Timer? _clockTick;
  String? _enteringReservationId;
  String? _cancellingReservationId;

  void _handleCalendarChanged() {
    if (!mounted) return;
    _reload();
  }

  static const _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  @override
  void initState() {
    super.initState();
    _future = _calendarService.getMyUpcoming(limit: _limit);
    StudentCalendarRefreshBus.notifier.addListener(_handleCalendarChanged);

    _clockTick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        // Rebuild to update the time-based CTA window.
      });
    });
  }

  @override
  void dispose() {
    StudentCalendarRefreshBus.notifier.removeListener(_handleCalendarChanged);
    _clockTick?.cancel();
    super.dispose();
  }

  void _loadMore() {
    setState(() {
      _limit += 4;
      _future = _calendarService.getMyUpcoming(limit: _limit);
    });
  }

  void _reload() {
    setState(() {
      _future = _calendarService.getMyUpcoming(limit: _limit);
    });
  }

  bool _canEnterLesson(StudentCalendarItemDto item) {
    final now = DateTime.now();
    final start = item.startTime.toLocal();
    final end = item.endTime.toLocal();
    final enterFrom = start.subtract(const Duration(minutes: 10));
    final enterUntil = end.add(const Duration(minutes: 15));
    return (now.isAfter(enterFrom) || now.isAtSameMomentAs(enterFrom)) &&
        (now.isBefore(enterUntil) || now.isAtSameMomentAs(enterUntil));
  }

  Future<void> _openPendingLessonReview(StudentCalendarItemDto item) async {
    final decision = await showPendingLessonReviewDialog(
      context,
      lesson: PendingLessonReviewData(
        idReservation: item.idReservation,
        subject: item.disciplinaName,
        teacherName: item.professorName,
        startTime: item.startTime,
        endTime: item.endTime,
        status: item.status,
      ),
      calendarService: _calendarService,
    );

    if (decision != null && mounted) {
      _reload();
    }
  }

  Future<void> _handlePrimaryAction(StudentCalendarItemDto item) async {
    if (isPendingCalendarStatus(item.status)) {
      await _openPendingLessonReview(item);
      return;
    }

    if (!_canEnterLesson(item)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Podes entrar na sessão 10 minutos antes do início e até 15 minutos após o fim.',
          ),
        ),
      );
      return;
    }

    if (_enteringReservationId == item.idReservation) return;
    setState(() => _enteringReservationId = item.idReservation);

    try {
      final entry = await _lessonClassroomService.enterClassroom(
        reservationId: item.idReservation,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LiveClassroomPage(entry: entry),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _enteringReservationId = null);
      }
    }
  }

  Future<void> _handleSecondaryAction(StudentCalendarItemDto item) async {
    if (isPendingCalendarStatus(item.status)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aceita ou revê primeiro o pedido da sessão antes de a cancelar.',
          ),
        ),
      );
      return;
    }

    if (_cancellingReservationId == item.idReservation) return;

    final timeUntilStart = item.startTime.difference(DateTime.now());
    final moreThan24Hours = timeUntilStart >= const Duration(hours: 24);

    if (moreThan24Hours) {
      final confirmed = await _showStandardCancellationDialog();
      if (confirmed != true) return;

      await _cancelLesson(item: item, lessThan24Hours: false);
      return;
    }

    final action = await _showLateCancellationDialog();
    if (action == null) return;

    if (action == _LateCancellationAction.cancelWithoutJustification) {
      await _cancelLesson(item: item, lessThan24Hours: true);
      return;
    }

    final justification = await _showJustificationDialog();
    if (justification == null || justification.trim().isEmpty) return;

    await _cancelLesson(
      item: item,
      lessThan24Hours: true,
      justification: justification.trim(),
    );
  }

  Future<bool?> _showStandardCancellationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B00)),
            SizedBox(width: 8),
            Text('Cancelar sessão'),
          ],
        ),
        content: const Text(
          'Tens a certeza que pretendes cancelar esta sessão?\n\nComo faltam mais de 24 horas, não sofrerás qualquer penalidade.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF04438),
            ),
            child: const Text(
              'Sim, cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<_LateCancellationAction?> _showLateCancellationDialog() {
    return showDialog<_LateCancellationAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Atenção: penalidade'),
          ],
        ),
        content: const Text(
          'Faltam menos de 24 horas para o início desta sessão.\n\nO cancelamento agora implica uma penalidade. Podes cancelar diretamente ou enviar uma justificação ao profissional.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(_LateCancellationAction.cancelWithoutJustification),
            child: const Text(
              'Cancelar sem justificar',
              style: TextStyle(color: Color(0xFFF04438)),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(_LateCancellationAction.justify),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
            ),
            child: const Text(
              'Justificar falta',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showJustificationDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Justificar cancelamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escreve o motivo do cancelamento. O profissional irá analisar o teu pedido.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ex: Tive um imprevisto médico...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.of(context).pop(value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
            ),
            child: const Text(
              'Enviar e cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _cancelLesson({
    required StudentCalendarItemDto item,
    required bool lessThan24Hours,
    String? justification,
  }) async {
    if (item.professorUserId == null || item.professorUserId!.trim().isEmpty) {
      throw const StudentCalendarException(
        'Não foi possível identificar o profissional desta sessão.',
      );
    }

    setState(() => _cancellingReservationId = item.idReservation);

    try {
      await _calendarService.cancelReservation(
        reservationId: item.idReservation,
      );

      final me = await _usersService.getMe();
      final studentName = _resolveStudentName(me);

      final type = lessThan24Hours
          ? (justification == null || justification.isEmpty
                ? 'Cancelamento Tardio'
                : 'Cancelamento Justificado')
          : 'Sessão Cancelada';

      final visibleMessage = !lessThan24Hours
          ? '$studentName cancelou a sessão de ${item.disciplinaName} com antecedência. O teu calendário foi libertado.'
          : (justification == null || justification.isEmpty
                ? '$studentName cancelou a sessão de ${item.disciplinaName} a menos de 24h sem apresentar justificação.'
                : '$studentName cancelou a sessão de ${item.disciplinaName} a menos de 24h e enviou uma justificação.');

      final message = _appendNotificationMetadata(visibleMessage, {
        'reservationId': item.idReservation,
        'studentUserId': me.id ?? '',
        'studentName': studentName,
        'teacherName': item.professorName,
        'subject': item.disciplinaName,
        'start': item.startTime.toUtc().toIso8601String(),
        'end': item.endTime.toUtc().toIso8601String(),
        'decisionMade': 'false',
        if (justification != null && justification.isNotEmpty)
          'justification': justification,
      });

      await _notificationsService.createNotification(
        idUser: item.professorUserId!,
        type: type,
        message: message,
      );

      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão cancelada com sucesso.'),
          backgroundColor: Color(0xFF00A63E),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _cancellingReservationId = null);
      }
    }
  }

  String _resolveStudentName(dynamic me) {
    final displayName = me.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final username = me.username?.trim();
    if (username != null && username.isNotEmpty) return username;

    return 'Aluno';
  }

  static String _appendNotificationMetadata(
    String message,
    Map<String, String> metadata,
  ) {
    final entries = metadata.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    if (entries.isEmpty) return message;
    return '$message [[$entries]]';
  }

  static String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatDateLabel(DateTime dt) {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = d0.add(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == d0) return '📅 Hoje';
    if (d == d1) return '📅 Amanhã';
    final dd = dt.day.toString().padLeft(2, '0');
    final m = (dt.month >= 1 && dt.month <= 12)
        ? _months[dt.month - 1]
        : dt.month.toString();
    return '📅 $dd $m';
  }

  static Color _accentForDisciplina(String disciplina) {
    final d = disciplina.toLowerCase();
    if (d.contains('mat')) return const Color(0xFF2B7FFF);
    if (d.contains('fís') || d.contains('fis')) return const Color(0xFF00C950);
    return const Color(0xFFFF6900);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentCalendarItemDto>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Color(0xFF4A5565)),
            ),
          );
        }

        final items = (snapshot.data ?? const <StudentCalendarItemDto>[])
            .where(
              (item) => normalizeCalendarStatus(item.status) != 'cancelled',
            )
            .toList(growable: false);
        if (items.isEmpty) {
          if (widget.isMobile) {
            return Column(
              children: [
                const _MobileUpcomingLessonsEmptyState(),
                const SizedBox(height: 16),
                CalendarioMobileCtaButton(
                  label: 'Marcar Nova Sessão',
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.explicadores),
                ),
              ],
            );
          }

          return const _UpcomingLessonsEmptyState();
        }

        final canLoadMore = items.length >= _limit;

        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              () {
                final now = DateTime.now();
                final item = items[i];
                final start = item.startTime.toLocal();
                final end = item.endTime.toLocal();
                final isPending = isPendingCalendarStatus(item.status);
                final palette = calendarStatusPalette(item.status);

                final enterFrom = start.subtract(const Duration(minutes: 10));
                final enterUntil = end.add(const Duration(minutes: 15));
                final canEnter =
                    !isPending &&
                    (now.isAfter(enterFrom) ||
                        now.isAtSameMomentAs(enterFrom)) &&
                    (now.isBefore(enterUntil) ||
                        now.isAtSameMomentAs(enterUntil));

                final isBeforeStart = now.isBefore(start);
                final minutesToStart = start.difference(now).inMinutes;

                final showStatus = isPending || canEnter;
                final statusLabel = showStatus
                    ? (isPending
                          ? calendarStatusLabel(item.status)
                          : (isBeforeStart
                                ? 'Em ${minutesToStart < 0 ? 0 : minutesToStart} minutos'
                                : 'A decorrer'))
                    : null;
                final statusBg = showStatus
                    ? (isPending ? palette.background : const Color(0xFFDCFCE7))
                    : null;
                final statusText = showStatus
                    ? (isPending ? palette.text : const Color(0xFF008236))
                    : null;

                if (widget.isMobile) {
                  final canShowCancel = !isPending;
                  final primaryGradient = canEnter || isPending
                      ? null
                      : CalendarioConstants.orangeGradient;
                  final primaryBackgroundColor = canEnter
                      ? CalendarioConstants.mobileSuccessColor
                      : isPending
                      ? CalendarioConstants.mobilePendingColor
                      : null;

                  return MobileUpcomingLessonCard(
                    accentColor: _accentForDisciplina(item.disciplinaName),
                    subject: item.disciplinaName,
                    teacherName: item.professorName,
                    statusLabel: statusLabel,
                    statusBackgroundColor: statusBg,
                    statusTextColor: statusText,
                    dateLabel: _formatDateLabel(
                      item.startTime,
                    ).replaceFirst('📅 ', ''),
                    timeLabel:
                        '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
                    primaryLabel: isPending
                        ? 'Rever pedido'
                        : canEnter
                        ? 'Entrar na Sessão'
                        : 'Ver Detalhes',
                    onPrimaryTap: () => _handlePrimaryAction(item),
                    onSecondaryTap: canShowCancel
                        ? () => _handleSecondaryAction(item)
                        : null,
                    secondaryIsLoading:
                        _cancellingReservationId == item.idReservation,
                    primaryGradient: primaryGradient,
                    primaryBackgroundColor: primaryBackgroundColor,
                    showPlayIcon: canEnter,
                  );
                }

                return _UpcomingLessonCard(
                  accentColor: _accentForDisciplina(item.disciplinaName),
                  subject: item.disciplinaName,
                  teacherName: item.professorName,
                  statusLabel: statusLabel,
                  statusBackgroundColor: statusBg,
                  statusTextColor: statusText,
                  dateLabel: _formatDateLabel(item.startTime),
                  timeLabel:
                      '🕐 ${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
                  primaryActionStyle: canEnter
                      ? _PrimaryActionStyle.enterClass
                      : _PrimaryActionStyle.viewDetails,
                  primaryActionLabel: isPending
                      ? 'Rever pedido'
                      : canEnter
                      ? 'Entrar na Sessão'
                      : 'Ver Detalhes',
                  onPrimaryTap: () => _handlePrimaryAction(item),
                  onSecondaryTap: isPending
                      ? null
                      : () => _handleSecondaryAction(item),
                  secondaryIsLoading:
                      _cancellingReservationId == item.idReservation,
                );
              }(),
              SizedBox(height: widget.isMobile ? 16 : 22.404),
            ],
            if (canLoadMore)
              SizedBox(
                width: double.infinity,
                height: widget.isMobile ? 52 : 84.017,
                child: OutlinedButton.icon(
                  onPressed: _loadMore,
                  icon: const Icon(
                    Icons.expand_more_rounded,
                    size: 24,
                    color: Color(0xFF4A5565),
                  ),
                  label: Text(
                    'Ver mais apoios',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 15 : 22.404,
                      fontWeight: widget.isMobile
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: const Color(0xFF4A5565),
                      height: widget.isMobile ? 22 / 15 : 33.607 / 22.404,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(2.801),
                    side: const BorderSide(
                      color: Color(0xFFD1D5DC),
                      width: 2.801,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.404),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            if (widget.isMobile) ...[
              const SizedBox(height: 16),
              CalendarioMobileCtaButton(
                label: 'Marcar Nova Sessão',
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.explicadores),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MobileUpcomingLessonsEmptyState extends StatelessWidget {
  const _MobileUpcomingLessonsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          CalendarioConstants.mobileCardRadius,
        ),
        border: Border.all(color: CalendarioConstants.mobileBorderColor),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFFFF7ED),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 28,
              color: CalendarioConstants.activeTabColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Ainda não tens próximos apoios marcados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CalendarioConstants.mobileTextColor,
              height: 28 / 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explora os profissionais disponíveis e agenda a tua próxima sessão.',
            textAlign: TextAlign.center,
            style: CalendarioConstants.mobileCardSubtitleStyle,
          ),
        ],
      ),
    );
  }
}

class _UpcomingLessonsEmptyState extends StatelessWidget {
  const _UpcomingLessonsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 35.007, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
        border: Border.all(
          color: CalendarioConstants.cardBorderColor,
          width: CalendarioConstants.cardBorderWidth,
        ),
        boxShadow: CalendarioConstants.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 34,
              color: Color(0xFFFF6B00),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ainda não tem próximas sessões marcadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
              height: 36 / 28,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Explore os profissionais disponíveis e reserve a sua próxima sessão!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 28 / 18,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: ChatsConstants.orangeGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.explicadores),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                  ),
                ),
                child: const Text('Marque a sua próxima sessão'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingLessonCard extends StatelessWidget {
  const _UpcomingLessonCard({
    required this.accentColor,
    required this.subject,
    required this.teacherName,
    this.statusLabel,
    this.statusBackgroundColor,
    this.statusTextColor,
    required this.dateLabel,
    required this.timeLabel,
    required this.primaryActionStyle,
    required this.primaryActionLabel,
    required this.onPrimaryTap,
    this.onSecondaryTap,
    this.secondaryIsLoading = false,
  });

  final Color accentColor;
  final String subject;
  final String teacherName;

  final String? statusLabel;
  final Color? statusBackgroundColor;
  final Color? statusTextColor;

  final String dateLabel;
  final String timeLabel;

  final _PrimaryActionStyle primaryActionStyle;
  final String primaryActionLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final bool secondaryIsLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 254.851,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 35.007,
          vertical: 35.007,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(
            color: CalendarioConstants.cardBorderColor,
            width: CalendarioConstants.cardBorderWidth,
          ),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 11.202,
              height: 89.618,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(23492794),
              ),
            ),
            const SizedBox(width: 22.404),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 25.205,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF101828),
                                height: 39.208 / 25.205,
                              ),
                            ),
                            Text(
                              'com $teacherName',
                              style: const TextStyle(
                                fontSize: 19.604,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4A5565),
                                height: 28.006 / 19.604,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statusLabel != null &&
                          statusBackgroundColor != null &&
                          statusTextColor != null)
                        Container(
                          height: 33.607,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.803,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            borderRadius: BorderRadius.circular(23492794),
                          ),
                          child: Text(
                            statusLabel!,
                            style: TextStyle(
                              fontSize: 16.803,
                              fontWeight: FontWeight.w500,
                              color: statusTextColor,
                              height: 22.404 / 16.803,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 11.202),
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 19.604,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5565),
                          height: 28.006 / 19.604,
                        ),
                      ),
                      const SizedBox(width: 33.607),
                      Flexible(
                        child: Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 19.604,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A5565),
                            height: 28.006 / 19.604,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _PrimaryActionButton(
                        style: primaryActionStyle,
                        label: primaryActionLabel,
                        onTap: onPrimaryTap,
                      ),
                      const SizedBox(width: 16.803),
                      _SecondaryIconButton(
                        onTap: onSecondaryTap,
                        isLoading: secondaryIsLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.style,
    required this.label,
    required this.onTap,
  });

  final _PrimaryActionStyle style;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      _PrimaryActionStyle.enterClass => SizedBox(
        width: 240.345,
        height: 56.011,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C950),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19.604),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Stack(
            children: [
              const Positioned(
                left: 33.607,
                top: (56.011 - 22.404) / 2,
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 22.404,
                  color: Colors.white,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22.404,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 33.607 / 22.404,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      _PrimaryActionStyle.viewDetails => _GradientButton(
        width: 193.359,
        height: 56.011,
        radius: 19.604,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22.404,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 33.607 / 22.404,
            ),
          ),
        ),
      ),
    };
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.onTap,
    required this.child,
  });

  final double width;
  final double height;
  final double radius;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SecondaryIconButton extends StatelessWidget {
  const _SecondaryIconButton({this.onTap, this.isLoading = false});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.014,
      height: 56.011,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFFFC9C9), width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19.604),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB2C36)),
                ),
              )
            : const Icon(
                Icons.close_rounded,
                size: 22.404,
                color: Color(0xFFFB2C36),
              ),
      ),
    );
  }
}