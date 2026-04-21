import 'dart:math' as math;

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/lesson_classroom/lesson_classroom_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/features/aluno/calendario/state/student_calendar_refresh_bus.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mobile_intro.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mode_tabs.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_day_card.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_header.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_stats_card.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/pending_lesson_review_dialog.dart';
import 'package:aula_extra/features/classroom/pages/live_classroom_page.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CalendarioSemanalContentSection extends StatelessWidget {
  const CalendarioSemanalContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    void onUpcomingTap() {
      Navigator.of(context).pushReplacementNamed(Routes.calendario);
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
              subtitle: 'Organize suas aulas e compromissos da semana.',
            ),
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            CalendarioModeTabs(
              activeMode: CalendarioMode.weekly,
              onUpcomingTap: onUpcomingTap,
              onWeeklyTap: () {},
              isMobile: true,
            ),
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            const _MobileWeeklyAgenda(),
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
          const AlunoMenuNav(selectedIndex: 2),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Calendário', style: CalendarioConstants.titleStyle),
                const SizedBox(height: 11.202),
                const Text(
                  'Organize suas aulas e compromissos',
                  style: CalendarioConstants.subtitleStyle,
                ),
                const SizedBox(height: 33.607),
                CalendarioModeTabs(
                  activeMode: CalendarioMode.weekly,
                  onUpcomingTap: onUpcomingTap,
                  onWeeklyTap: () {},
                  isMobile: false,
                ),
                const SizedBox(height: 22.404),
                const _WeeklyCalendarCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileWeeklyAgenda extends StatefulWidget {
  const _MobileWeeklyAgenda();

  @override
  State<_MobileWeeklyAgenda> createState() => _MobileWeeklyAgendaState();
}

class _MobileWeeklyAgendaState extends State<_MobileWeeklyAgenda> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  final LessonClassroomService _lessonClassroomService =
      LessonClassroomService();
  late Future<List<StudentCalendarItemDto>> _future;
  int _weekOffset = 0;
  String? _enteringReservationId;

  static const _days = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

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

  static DateTime _startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static String _toIsoDate(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _handleCalendarChanged() {
    if (!mounted) return;
    setState(_loadWeek);
  }

  void _loadWeek() {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    _future = _calendarService.getMyWeek(weekStart: _toIsoDate(weekStart));
  }

  @override
  void initState() {
    super.initState();
    _loadWeek();
    StudentCalendarRefreshBus.notifier.addListener(_handleCalendarChanged);
  }

  @override
  void dispose() {
    StudentCalendarRefreshBus.notifier.removeListener(_handleCalendarChanged);
    super.dispose();
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
      setState(_loadWeek);
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
            'Podes entrar na aula 10 minutos antes do início e até 15 minutos após o fim.',
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

  static String _formatClock(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatWeekLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startMonth = _months[weekStart.month - 1];
    final endMonth = _months[weekEnd.month - 1];
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} - ${weekEnd.day} $endMonth ${weekEnd.year}';
    }
    return '${weekStart.day} $startMonth - ${weekEnd.day} $endMonth ${weekEnd.year}';
  }

  static String _formatDayTitle(DateTime date) {
    return '${_days[date.weekday - 1]}, ${date.day}';
  }

  static String _formatDuration(StudentCalendarItemDto item) {
    final minutes = item.endTime.difference(item.startTime).inMinutes;
    return '${minutes.clamp(0, 999)}min';
  }

  static String _nextLessonLabel(List<StudentCalendarItemDto> items) {
    final now = DateTime.now();
    final upcoming =
        items
            .where((item) => item.startTime.isAfter(now))
            .toList(growable: false)
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (upcoming.isEmpty) return '—';

    final diff = upcoming.first.startTime.difference(now);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} h';
    }
    return '${diff.inDays} dia${diff.inDays == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    final today = DateTime.now();

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
              style: const TextStyle(color: Color(0xFF6A7282)),
            ),
          );
        }

        final items =
            (snapshot.data ?? const <StudentCalendarItemDto>[])
                .where(
                  (item) => normalizeCalendarStatus(item.status) != 'cancelled',
                )
                .toList(growable: false)
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

        final pendingTasks = items
            .where((item) => isPendingCalendarStatus(item.status))
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileWeekHeader(
              label: _formatWeekLabel(weekStart),
              onPreviousTap: () {
                setState(() {
                  _weekOffset -= 1;
                  _loadWeek();
                });
              },
              onNextTap: () {
                setState(() {
                  _weekOffset += 1;
                  _loadWeek();
                });
              },
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < 7; index++) ...[
              () {
                final date = weekStart.add(Duration(days: index));
                final dayItems = items
                    .where((item) {
                      return _isSameDate(item.startTime, date);
                    })
                    .toList(growable: false);

                return MobileWeekDayCard(
                  title: _formatDayTitle(date),
                  isToday: _isSameDate(date, today),
                  children: dayItems.isEmpty
                      ? const [MobileWeekEmptyState()]
                      : dayItems
                            .map((item) {
                              final canEnter = _canEnterLesson(item);
                              final isPending = isPendingCalendarStatus(
                                item.status,
                              );
                              final actionLabel = isPending
                                  ? 'Rever pedido'
                                  : canEnter
                                  ? 'Entrar na Aula'
                                  : 'Ver Detalhes';

                              return MobileWeekLessonTile(
                                subject: item.disciplinaName,
                                teacher: item.professorName,
                                timeRange:
                                    '${_formatClock(item.startTime)} • ${_formatClock(item.endTime)}',
                                durationLabel:
                                    _enteringReservationId == item.idReservation
                                    ? 'A entrar...'
                                    : _formatDuration(item),
                                actionLabel: actionLabel,
                                onActionTap: () => _handlePrimaryAction(item),
                                useSuccessButton: canEnter,
                              );
                            })
                            .toList(growable: false),
                );
              }(),
              if (index < 6) const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            MobileWeekStatsCard(
              weekLessons: items.length,
              pendingTasks: pendingTasks,
              nextLessonLabel: _nextLessonLabel(items),
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  const _WeeklyCalendarCard();

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (viewportHeight - 320).clamp(420.0, 720.0);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(
            color: CalendarioConstants.cardBorderColor,
            width: CalendarioConstants.cardBorderWidth,
          ),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: const _WeeklyCalendarGrid(),
      ),
    );
  }
}

class _WeeklyCalendarGrid extends StatefulWidget {
  const _WeeklyCalendarGrid();

  @override
  State<_WeeklyCalendarGrid> createState() => _WeeklyCalendarGridState();
}

class _WeeklyCalendarGridState extends State<_WeeklyCalendarGrid> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  late Future<List<StudentCalendarItemDto>> _future;
  int _weekOffset = 0;

  static const double _timeColumnWidth = 56;
  static const double _dayGap = 8;
  static const double _slotHeight = 34;

  static const _todayHeaderBackground = Color(0xFFFFF7ED);
  static const _todayHeaderBorder = Color(0xFFFFD7BA);
  static const _todayCellBackground = Color(0xFFFFFBF5);
  static const _todayCellBorder = Color(0xFFFEB273);

  static const _headerTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF101828),
  );

  static const _subHeaderTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6A7282),
  );

  static const _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

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

  static String _formatDay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final m = (d.month >= 1 && d.month <= 12)
        ? _months[d.month - 1]
        : d.month.toString();
    return '$dd $m';
  }

  static DateTime _startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static String _toIsoDate(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static (int, int) _visibleSlotRangeForWeek(
    List<StudentCalendarItemDto> items,
    DateTime weekStart,
  ) {
    var earliestSlot = 47;
    var latestSlot = 1;
    var hasLessons = false;

    for (final item in items) {
      final dayKey = DateTime(
        item.startTime.year,
        item.startTime.month,
        item.startTime.day,
      );
      final dayIndex = dayKey.difference(weekStart).inDays;
      if (dayIndex < 0 || dayIndex > 6) continue;

      hasLessons = true;
      final startSlot = _slotFloor(item.startTime);
      final endSlot = _slotCeil(item.endTime);
      earliestSlot = math.min(earliestSlot, startSlot);
      latestSlot = math.max(latestSlot, endSlot);
    }

    if (!hasLessons) {
      return (0, 48);
    }

    final startSlot = math.max(0, earliestSlot - 1);
    final endSlot = math.min(48, math.max(startSlot + 2, latestSlot + 1));
    return (startSlot, endSlot);
  }

  static int _slotFloor(DateTime value) =>
      ((value.hour * 60) + value.minute) ~/ 30;

  static int _slotCeil(DateTime value) =>
      (((value.hour * 60) + value.minute) / 30).ceil();

  static int _minutesSinceDayStart(DateTime value) =>
      (value.hour * 60) + value.minute;

  static String _formatSlotLabel(int slot) {
    final hour = slot ~/ 2;
    final minute = slot.isOdd ? '30' : '00';
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  static String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatClock(start)} · ${_formatClock(end)}';
  }

  static String _formatClock(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  _WeeklyLessonPalette _paletteForLesson(StudentCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) {
      return const _WeeklyLessonPalette(
        background: Color(0xFFFFF7E8),
        border: Color(0xFFF59E0B),
        title: Color(0xFF9A6700),
        subtitle: Color(0xFFB54708),
      );
    }

    if (item.endTime.isBefore(DateTime.now())) {
      return const _WeeklyLessonPalette(
        background: Color(0xFFF2F4F7),
        border: Color(0xFFD0D5DD),
        title: Color(0xFF344054),
        subtitle: Color(0xFF667085),
      );
    }

    return const _WeeklyLessonPalette(
      background: Color(0xFFECFDF3),
      border: Color(0xFF12B76A),
      title: Color(0xFF027A48),
      subtitle: Color(0xFF039855),
    );
  }

  void _handleCalendarChanged() {
    if (!mounted) return;
    setState(_loadWeek);
  }

  void _loadWeek() {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    _future = _calendarService.getMyWeek(weekStart: _toIsoDate(weekStart));
  }

  @override
  void initState() {
    super.initState();
    _loadWeek();
    StudentCalendarRefreshBus.notifier.addListener(_handleCalendarChanged);
  }

  @override
  void dispose() {
    StudentCalendarRefreshBus.notifier.removeListener(_handleCalendarChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    final today = DateTime.now();
    final todayIndex = _weekOffset == 0 ? today.weekday - 1 : -1;
    final days = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return (_days[i], _formatDay(date), date);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Semana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _weekOffset -= 1;
                      _loadWeek();
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _weekOffset += 1;
                      _loadWeek();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(width: 52),
            ...days.indexed.map((entry) {
              final index = entry.$1;
              final day = entry.$2;
              final isTodayColumn =
                  index == todayIndex && _isSameDate(day.$3, today);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isTodayColumn
                        ? _todayHeaderBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTodayColumn
                          ? _todayHeaderBorder
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.$1,
                        style: _headerTextStyle.copyWith(
                          color: isTodayColumn
                              ? CalendarioConstants.activeTabColor
                              : _headerTextStyle.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.$2,
                        style: _subHeaderTextStyle.copyWith(
                          color: isTodayColumn
                              ? const Color(0xFFB93815)
                              : _subHeaderTextStyle.color,
                          fontWeight: isTodayColumn
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<StudentCalendarItemDto>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Color(0xFF6A7282)),
                  ),
                );
              }

              final items = snapshot.data ?? const <StudentCalendarItemDto>[];
              final visibleRange = _visibleSlotRangeForWeek(items, weekStart);
              final startSlot = visibleRange.$1;
              final endSlot = visibleRange.$2;
              final slotCount = endSlot - startSlot;
              final totalHeight = slotCount * _slotHeight;

              return SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _timeColumnWidth,
                        height: totalHeight,
                        child: Column(
                          children: List.generate(slotCount, (index) {
                            final slot = startSlot + index;
                            return SizedBox(
                              height: _slotHeight,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    _formatSlotLabel(slot),
                                    style: TextStyle(
                                      fontSize: slot.isOdd ? 11 : 12,
                                      color: slot.isOdd
                                          ? const Color(0xFF98A2B3)
                                          : const Color(0xFF6A7282),
                                      fontWeight: slot.isOdd
                                          ? FontWeight.w400
                                          : FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: _dayGap),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columnWidth =
                                (constraints.maxWidth - (_dayGap * 6)) / 7;

                            return SizedBox(
                              height: totalHeight,
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(7, (dayIndex) {
                                      final isTodayColumn =
                                          dayIndex == todayIndex;

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: dayIndex == 0 ? 0 : _dayGap,
                                        ),
                                        child: Container(
                                          width: columnWidth,
                                          decoration: BoxDecoration(
                                            color: isTodayColumn
                                                ? _todayCellBackground
                                                : const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isTodayColumn
                                                  ? _todayCellBorder
                                                  : const Color(0xFFE5E7EB),
                                              width: isTodayColumn ? 1.2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: List.generate(slotCount, (
                                              index,
                                            ) {
                                              final slot = startSlot + index;
                                              return Container(
                                                height: _slotHeight,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: index == 0
                                                          ? Colors.transparent
                                                          : (slot.isOdd
                                                                ? const Color(
                                                                    0xFFF2F4F7,
                                                                  )
                                                                : const Color(
                                                                    0xFFE5E7EB,
                                                                  )),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  ...items.map((item) {
                                    final dayKey = DateTime(
                                      item.startTime.year,
                                      item.startTime.month,
                                      item.startTime.day,
                                    );
                                    final dayIndex = dayKey
                                        .difference(weekStart)
                                        .inDays;
                                    if (dayIndex < 0 || dayIndex > 6) {
                                      return const SizedBox.shrink();
                                    }

                                    final startOffset =
                                        (_minutesSinceDayStart(item.startTime) /
                                            30) -
                                        startSlot;
                                    final endOffset =
                                        (_minutesSinceDayStart(item.endTime) /
                                            30) -
                                        startSlot;

                                    final top = (startOffset * _slotHeight) + 2;
                                    final height = math.max(
                                      _slotHeight - 4,
                                      ((endOffset - startOffset) *
                                              _slotHeight) -
                                          4,
                                    );
                                    final left =
                                        (dayIndex * (columnWidth + _dayGap)) +
                                        4;
                                    final palette = _paletteForLesson(item);

                                    return Positioned(
                                      top: top,
                                      left: left,
                                      width: columnWidth - 8,
                                      height: height.toDouble(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: palette.background,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: palette.border,
                                            width: 1.2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                16,
                                                24,
                                                40,
                                                0.06,
                                              ),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item.professorName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: palette.title,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.disciplinaName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: palette.subtitle,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTimeRange(
                                                item.startTime,
                                                item.endTime,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: palette.subtitle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeeklyLessonPalette {
  const _WeeklyLessonPalette({
    required this.background,
    required this.border,
    required this.title,
    required this.subtitle,
  });

  final Color background;
  final Color border;
  final Color title;
  final Color subtitle;
}
