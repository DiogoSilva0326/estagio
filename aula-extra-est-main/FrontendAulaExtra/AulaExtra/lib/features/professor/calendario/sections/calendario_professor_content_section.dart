import 'dart:math' as math;

import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/lesson_classroom/lesson_classroom_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mobile_cta_button.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mobile_intro.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/calendario_mode_tabs.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_upcoming_lesson_card.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_day_card.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_header.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/mobile_week_stats_card.dart';
import 'package:aula_extra/features/classroom/pages/live_classroom_page.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_layout.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_mock_data.dart';
import 'package:aula_extra/features/professor/calendario/widgets/aula_card.dart';
import 'package:aula_extra/features/professor/calendario/widgets/calendario_tabs.dart';
import 'package:aula_extra/features/professor/calendario/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/calendario/widgets/marcar_aula_dialog.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class CalendarioProfessorContentSection extends StatefulWidget {
  const CalendarioProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<CalendarioProfessorContentSection> createState() =>
      _CalendarioProfessorContentSectionState();
}

class _CalendarioProfessorContentSectionState
    extends State<CalendarioProfessorContentSection> {
  int _selectedTab = 0;
  Key _upcomingListKey = UniqueKey();
  Key _weeklyCardKey = UniqueKey();

  Future<void> _handleAddLesson() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const MarcarAulaDialog(),
    );

    if (result == true && mounted) {
      setState(() {
        _upcomingListKey = UniqueKey();
        _weeklyCardKey = UniqueKey();
      });
    }
  }

  Widget _buildMobileContent(TeachingRoleConfig config) {
    return Container(
      width: double.infinity,
      color: CalendarioConstants.backgroundColor,
      padding: const EdgeInsets.fromLTRB(
        CalendarioConstants.mobileHorizontalPadding,
        CalendarioConstants.mobileVerticalPadding,
        CalendarioConstants.mobileHorizontalPadding,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarioMobileIntro(
            title: 'Calendário',
            subtitle:
                'Acompanhe as próximas ${config.sessionsLabel} e a sua agenda semanal num único lugar.', 
          ),
          const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
          CalendarioMobileCtaButton(
            label: 'Adicionar Horário',
            icon: Icons.add_circle_outline_rounded,
            onTap: _handleAddLesson,
          ),
          const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
          CalendarioModeTabs(
            activeMode: _selectedTab == 0
                ? CalendarioMode.upcoming
                : CalendarioMode.weekly,
            onUpcomingTap: () {
              if (_selectedTab == 0) return;
              setState(() => _selectedTab = 0);
            },
            onWeeklyTap: () {
              if (_selectedTab == 1) return;
              setState(() => _selectedTab = 1);
            },
            isMobile: true,
          ),
          const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
          if (_selectedTab == 0)
            _ProfessorUpcomingLessonsList(
                key: _upcomingListKey, isMobile: true, config: config)
          else
            _ProfessorMobileWeeklyAgenda(
                key: _weeklyCardKey, config: config),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final isMobile =
        widget.isMobile ||
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    final titleStyle = TextStyle(
      color: CalendarioProfessorColors.title,
      fontWeight: FontWeight.w700,
      fontSize: CalendarioProfessorLayout.titleFontSize,
      height:
          CalendarioProfessorLayout.titleLineHeight /
          CalendarioProfessorLayout.titleFontSize,
    );

    if (isMobile) {
      return _buildMobileContent(config);
    }

    return Container(
      color: CalendarioProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: CalendarioProfessorLayout.pageLeftPadding,
            right: CalendarioProfessorLayout.pageRightPadding,
            top: CalendarioProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 2),
              const SizedBox(
                width: CalendarioProfessorLayout.sidebarContentGap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: CalendarioProfessorLayout.contentPadding,
                    left: CalendarioProfessorLayout.contentPadding,
                    right: CalendarioProfessorLayout.contentPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: CalendarioProfessorLayout.titleLineHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Calendário', style: titleStyle),
                            _AddHorarioButton(onTap: _handleAddLesson, config: config),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: CalendarioProfessorLayout.contentGap,
                      ),
                      CalendarioTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (index) =>
                            setState(() => _selectedTab = index),
                      ),
                      const SizedBox(height: 37.813),
                      if (_selectedTab == 0)
                        _ProfessorUpcomingLessonsList(
                          key: _upcomingListKey,
                          isMobile: false,
                          config: config,
                        )
                      else
                        _ProfessorWeeklyCalendarCard(
                            key: _weeklyCardKey, config: config),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessorUpcomingLessonsList extends StatefulWidget {
  const _ProfessorUpcomingLessonsList({
    super.key,
    required this.isMobile,
    required this.config,
  });

  final bool isMobile;
  final TeachingRoleConfig config;

  @override
  State<_ProfessorUpcomingLessonsList> createState() =>
      _ProfessorUpcomingLessonsListState();
}

class _ProfessorUpcomingLessonsListState
    extends State<_ProfessorUpcomingLessonsList> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  final LessonClassroomService _lessonClassroomService =
      LessonClassroomService();
  late Future<List<ProfessorCalendarItemDto>> _future;
  int _limit = 4;
  String? _enteringReservationId;
  String? _cancellingReservationId;

  static const _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  @override
  void initState() {
    super.initState();
    _future = _calendarService.getProfessorUpcoming(
      limit: _limit,
      role: context.read<UserProvider>().role,
    );
  }

  void _loadMore() {
    setState(() {
      _limit += 4;
      _future = _calendarService.getProfessorUpcoming(
        limit: _limit,
        role: context.read<UserProvider>().role,
      );
    });
  }

  void _reload() {
    setState(() {
      _future = _calendarService.getProfessorUpcoming(
        limit: _limit,
        role: context.read<UserProvider>().role,
      );
    });
  }

  String _formatWeekdayAndDate(DateTime dt) {
    const weekdays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
    ];
    final weekday = weekdays[dt.weekday - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final month = _months[dt.month - 1];
    return '$weekday, $day $month';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    String format(DateTime date) =>
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${format(start)} - ${format(end)}';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'AL';
    }
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  bool _canEnterLesson(ProfessorCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) {
      return false;
    }

    final now = DateTime.now();
    final start = item.startTime.toLocal();
    final end = item.endTime.toLocal();
    final enterFrom = start.subtract(const Duration(minutes: 10));
    final enterUntil = end.add(const Duration(minutes: 15));

    final afterStartWindow =
        now.isAfter(enterFrom) || now.isAtSameMomentAs(enterFrom);
    final beforeEndWindow =
        now.isBefore(enterUntil) || now.isAtSameMomentAs(enterUntil);

    return afterStartWindow && beforeEndWindow;
  }

  Future<void> _handleEnterLesson(ProfessorCalendarItemDto item) async {
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

  Future<void> _cancelLesson(ProfessorCalendarItemDto item) async {
    if (_cancellingReservationId == item.idReservation) return;

    setState(() => _cancellingReservationId = item.idReservation);

    try {
      await _calendarService.cancelReservationAsProfessor(
        reservationId: item.idReservation,
      );

      if (!mounted) return;
      _reload();
      final capitalizedSession = widget.config.sessionsLabel == 'aulas' ? 'Aula' : 'Sessão';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$capitalizedSession cancelada com sucesso.'),
          backgroundColor: const Color(0xFF00A63E),
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

  void _showEnterLessonInfo() {
    final sessionTerm = widget.config.sessionsLabel == 'aulas' ? 'aula' : 'sessão';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pode entrar na $sessionTerm 10 minutos antes do início e até 15 minutos após o fim.',
        ),
      ),
    );
  }

  void _showPendingInfo() {
    final sessionTerm = widget.config.sessionsLabel == 'aulas' ? 'aula' : 'sessão';
    final targetLabel = widget.config.roleName == 'Explicador' ? 'aluno' : 'membro';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Esta $sessionTerm ainda está a aguardar confirmação do $targetLabel.'),
      ),
    );
  }

  String _mobileStatusLabel(ProfessorCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) return 'Pendente';
    if (normalizeCalendarStatus(item.status) == 'cancelled') return 'Cancelada';
    return 'Confirmada';
  }

  Color _mobileStatusBackground(ProfessorCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) return const Color(0xFFFFF7E8);
    if (normalizeCalendarStatus(item.status) == 'cancelled') {
      return const Color(0xFFF2F4F7);
    }
    return const Color(0xFFECFDF3);
  }

  Color _mobileStatusTextColor(ProfessorCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) return const Color(0xFFB54708);
    if (normalizeCalendarStatus(item.status) == 'cancelled') {
      return const Color(0xFF667085);
    }
    return const Color(0xFF027A48);
  }

  String _mobilePrimaryLabel(ProfessorCalendarItemDto item, bool canEnter) {
    if (isPendingCalendarStatus(item.status)) return 'A aguardar confirmação';
    if (canEnter) return widget.config.marcarAula.joinSessionLabel;
    return 'Ver horário';
  }

  VoidCallback _mobilePrimaryAction(
    ProfessorCalendarItemDto item,
    bool canEnter,
  ) {
    if (isPendingCalendarStatus(item.status)) {
      return _showPendingInfo;
    }
    if (canEnter) {
      return () => _handleEnterLesson(item);
    }
    return _showEnterLessonInfo;
  }

  Widget _buildMobileEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CalendarioConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(
          CalendarioConstants.mobileCardRadius,
        ),
        border: Border.all(color: CalendarioConstants.mobileBorderColor),
        boxShadow: CalendarioConstants.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 28,
            color: CalendarioConstants.activeTabColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Ainda não tem ${widget.config.sessionsLabel} marcadas',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CalendarioConstants.mobileTextColor,
              height: 28 / 20,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quando existirem novas reservas, elas aparecem aqui para poder acompanhar rapidamente.',
            style: CalendarioConstants.mobileCardSubtitleStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProfessorCalendarItemDto>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Color(0xFF4A5565)),
            ),
          );
        }

        final items = snapshot.data ?? const <ProfessorCalendarItemDto>[];
        if (items.isEmpty) {
          if (widget.isMobile) {
            return _buildMobileEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Ainda não tem ${widget.config.sessionsLabel} marcadas.',
              style: const TextStyle(fontSize: 18, color: Color(0xFF6A7282)),
            ),
          );
        }

        final canLoadMore = items.length >= _limit;

        if (widget.isMobile) {
          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Builder(
                  builder: (context) {
                    final item = items[index];
                    final canEnter = _canEnterLesson(item);
                    final studentName = item.studentName.trim().isEmpty
                        ? 'Membro'
                        : item.studentName.trim();

                    final Gradient? dynamicGradient = isPendingCalendarStatus(item.status) || canEnter 
                        ? null 
                        : LinearGradient(colors: [widget.config.primaryColor, widget.config.primaryColor.withOpacity(0.8)]);

                    return MobileUpcomingLessonCard(
                      accentColor: widget.config.primaryColor, 
                      subject: item.disciplinaName,
                      teacherName: studentName,
                      dateLabel: _formatWeekdayAndDate(
                        item.startTime.toLocal(),
                      ),
                      timeLabel: _formatTimeRange(
                        item.startTime.toLocal(),
                        item.endTime.toLocal(),
                      ),
                      primaryLabel: _mobilePrimaryLabel(item, canEnter),
                      onPrimaryTap: _mobilePrimaryAction(item, canEnter),
                      onSecondaryTap:
                          normalizeCalendarStatus(item.status) == 'cancelled' ||
                                  _cancellingReservationId == item.idReservation
                              ? null
                              : () => _cancelLesson(item),
                      primaryBackgroundColor:
                          isPendingCalendarStatus(item.status)
                          ? CalendarioConstants.mobilePendingColor
                          : (canEnter
                                ? widget.config.primaryColor
                                : null),
                      primaryGradient: dynamicGradient,
                      statusLabel: _mobileStatusLabel(item),
                      statusBackgroundColor: _mobileStatusBackground(item),
                      statusTextColor: _mobileStatusTextColor(item),
                      secondaryIsLoading:
                          _cancellingReservationId == item.idReservation,
                      showPlayIcon:
                          canEnter && !isPendingCalendarStatus(item.status),
                    );
                  },
                ),
                if (index != items.length - 1)
                  const SizedBox(
                    height: CalendarioConstants.mobileSectionSpacing,
                  ),
              ],
              if (canLoadMore) ...[
                const SizedBox(
                  height: CalendarioConstants.mobileSectionSpacing,
                ),
                CalendarioMobileCtaButton(
                  label: 'Ver mais ${widget.config.sessionsLabel}', 
                  icon: Icons.expand_more_rounded,
                  onTap: _loadMore,
                ),
              ],
            ],
          );
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: CalendarioProfessorLayout.listGap),
              itemBuilder: (context, index) {
                final item = items[index];
                final canEnter = _canEnterLesson(item);
                final isPending = isPendingCalendarStatus(item.status);
                final isCancelled =
                    normalizeCalendarStatus(item.status) == 'cancelled';
                final studentName = item.studentName.trim().isEmpty
                    ? 'Aluno/Membro'
                    : item.studentName.trim();
                
                final targetLabel = widget.config.roleName == 'Explicador' ? 'aluno' : 'membro';

                final data = ProfessorAulaCardData(
                  initials: _initials(studentName),
                  color: widget.config.primaryColor,
                  studentName: studentName,
                  subject: item.disciplinaName,
                  weekdayAndDate: _formatWeekdayAndDate(
                    item.startTime.toLocal(),
                  ),
                  timeRange: _formatTimeRange(
                    item.startTime.toLocal(),
                    item.endTime.toLocal(),
                  ),
                  primaryActionLabel: isPending
                      ? 'A aguardar $targetLabel'
                      : widget.config.marcarAula.joinSessionLabel, 
                  primaryActionEnabled: canEnter,
                  showPrimaryAction: true,
                );
                return AulaCard(
                  data: data,
                  onEnterTap:
                      canEnter && _enteringReservationId != item.idReservation
                      ? () => _handleEnterLesson(item)
                      : null,
                  onCancelTap:
                      isCancelled ||
                              _cancellingReservationId == item.idReservation
                      ? null
                      : () => _cancelLesson(item),
                );
              },
            ),
            if (canLoadMore) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _loadMore,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: Text('Ver mais ${widget.config.sessionsLabel}'), 
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProfessorMobileWeeklyAgenda extends StatefulWidget {
  const _ProfessorMobileWeeklyAgenda({super.key, required this.config});

  final TeachingRoleConfig config;

  @override
  State<_ProfessorMobileWeeklyAgenda> createState() =>
      _ProfessorMobileWeeklyAgendaState();
}

class _ProfessorMobileWeeklyAgendaState
    extends State<_ProfessorMobileWeeklyAgenda> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  final LessonClassroomService _lessonClassroomService =
      LessonClassroomService();

  late Future<List<ProfessorCalendarItemDto>> _future;
  int _weekOffset = 0;
  String? _enteringReservationId;

  static const _days = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
  ];

  static const _months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
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

  static String _formatClock(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatDuration(ProfessorCalendarItemDto item) {
    final minutes = item.endTime.difference(item.startTime).inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    if (hours > 0) return '${hours}h';
    return '${remainingMinutes}m';
  }

  String _nextLessonLabel(List<ProfessorCalendarItemDto> items) {
    if (items.isEmpty) return 'Sem ${widget.config.sessionsLabel}'; 
    final now = DateTime.now();
    final futureItems =
        items.where((item) => item.startTime.isAfter(now)).toList()..sort(
          (first, second) => first.startTime.compareTo(second.startTime),
        );

    if (futureItems.isEmpty) return 'Esta semana';

    final next = futureItems.first.startTime.toLocal();
    return '${next.day.toString().padLeft(2, '0')} ${_months[next.month - 1]} · ${_formatClock(next)}';
  }

  void _loadWeek() {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    _future = _calendarService.getProfessorWeek(
      weekStart: _toIsoDate(weekStart),
      role: context.read<UserProvider>().role,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  bool _canEnterLesson(ProfessorCalendarItemDto item) {
    if (isPendingCalendarStatus(item.status)) {
      return false;
    }

    final now = DateTime.now();
    final start = item.startTime.toLocal();
    final end = item.endTime.toLocal();
    final enterFrom = start.subtract(const Duration(minutes: 10));
    final enterUntil = end.add(const Duration(minutes: 15));

    return (now.isAfter(enterFrom) || now.isAtSameMomentAs(enterFrom)) &&
        (now.isBefore(enterUntil) || now.isAtSameMomentAs(enterUntil));
  }

  Future<void> _handlePrimaryAction(ProfessorCalendarItemDto item) async {
    if (isPendingCalendarStatus(item.status)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta marcação ainda está a aguardar confirmação.',
          ),
        ),
      );
      return;
    }

    if (!_canEnterLesson(item)) {
      if (!mounted) return;
      final sessionTerm = widget.config.sessionsLabel == 'aulas' ? 'aula' : 'sessão';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pode entrar na $sessionTerm 10 minutos antes do início e até 15 minutos após o fim.',
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

  @override
  Widget build(BuildContext context) {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final label =
        '${weekStart.day.toString().padLeft(2, '0')} ${_months[weekStart.month - 1]} - ${weekEnd.day.toString().padLeft(2, '0')} ${_months[weekEnd.month - 1]}';

    return FutureBuilder<List<ProfessorCalendarItemDto>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CalendarioConstants.mobileSurfaceColor,
              borderRadius: BorderRadius.circular(
                CalendarioConstants.mobileCardRadius,
              ),
              border: Border.all(color: CalendarioConstants.mobileBorderColor),
            ),
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Color(0xFF6A7282)),
            ),
          );
        }

        final items =
            (snapshot.data ?? const <ProfessorCalendarItemDto>[])
                .where(
                  (item) => normalizeCalendarStatus(item.status) != 'cancelled',
                )
                .toList()
              ..sort(
                (first, second) => first.startTime.compareTo(second.startTime),
              );
        final pendingCount = items
            .where((item) => isPendingCalendarStatus(item.status))
            .length;
        final today = DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileWeekHeader(
              label: label,
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
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            for (var dayIndex = 0; dayIndex < 7; dayIndex++) ...[
              Builder(
                builder: (context) {
                  final date = weekStart.add(Duration(days: dayIndex));
                  final dayItems = items.where((item) {
                    final localStart = item.startTime.toLocal();
                    return _isSameDate(localStart, date);
                  }).toList();

                  return MobileWeekDayCard(
                    title:
                        '${_days[dayIndex]} · ${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]}',
                    isToday: _isSameDate(date, today),
                    children: dayItems.isEmpty
                        ? [
                            MobileWeekEmptyState(
                              label: 'Sem ${widget.config.sessionsLabel} agendadas para este dia', 
                            ),
                          ]
                        : [
                            for (final item in dayItems)
                              MobileWeekLessonTile(
                                subject: item.disciplinaName,
                                teacher: item.studentName.trim().isEmpty
                                    ? 'Aluno'
                                    : item.studentName.trim(),
                                timeRange:
                                    '${_formatClock(item.startTime.toLocal())} - ${_formatClock(item.endTime.toLocal())}',
                                durationLabel: _formatDuration(item),
                                actionLabel:
                                    isPendingCalendarStatus(item.status)
                                    ? 'A aguardar confirmação'
                                    : (_canEnterLesson(item)
                                        ? widget.config.marcarAula.joinSessionLabel 
                                        : 'Ver horário'),
                                onActionTap: () => _handlePrimaryAction(item),
                                useSuccessButton:
                                    _canEnterLesson(item) &&
                                    !isPendingCalendarStatus(item.status),
                              ),
                          ],
                  );
                },
              ),
              if (dayIndex != 6)
                const SizedBox(
                  height: CalendarioConstants.mobileSectionSpacing,
                ),
            ],
            const SizedBox(height: CalendarioConstants.mobileSectionSpacing),
            MobileWeekStatsCard(
              weekLessons: items.length,
              pendingTasks: pendingCount,
              nextLessonLabel: _nextLessonLabel(items),
            ),
          ],
        );
      },
    );
  }
}

class _ProfessorWeeklyCalendarCard extends StatelessWidget {
  const _ProfessorWeeklyCalendarCard({super.key, required this.config});

  final TeachingRoleConfig config;

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
        child: _ProfessorWeeklyCalendarGrid(config: config), 
      ),
    );
  }
}

class _ProfessorWeeklyCalendarGrid extends StatefulWidget {
  const _ProfessorWeeklyCalendarGrid({required this.config});

  final TeachingRoleConfig config;

  @override
  State<_ProfessorWeeklyCalendarGrid> createState() =>
      _ProfessorWeeklyCalendarGridState();
}

class _ProfessorWeeklyCalendarGridState
    extends State<_ProfessorWeeklyCalendarGrid> {
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  late Future<List<ProfessorCalendarItemDto>> _future;
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
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  static DateTime _startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static String _toIsoDate(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  static String _formatDay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]}';
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static (int, int) _visibleSlotRangeForWeek(
    List<ProfessorCalendarItemDto> items,
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

  _ProfessorWeeklyLessonPalette _paletteForLesson(
    ProfessorCalendarItemDto item,
  ) {
    if (isPendingCalendarStatus(item.status)) {
      return const _ProfessorWeeklyLessonPalette(
        background: Color(0xFFFFF7E8),
        border: Color(0xFFF59E0B),
        title: Color(0xFF9A6700),
        subtitle: Color(0xFFB54708),
      );
    }

    if (item.endTime.isBefore(DateTime.now())) {
      return const _ProfessorWeeklyLessonPalette(
        background: Color(0xFFF2F4F7),
        border: Color(0xFFD0D5DD),
        title: Color(0xFF344054),
        subtitle: Color(0xFF667085),
      );
    }

    return _ProfessorWeeklyLessonPalette(
      background: widget.config.primaryColor.withOpacity(0.12),
      border: widget.config.primaryColor,
      title: widget.config.primaryColor.withOpacity(0.9),
      subtitle: widget.config.primaryColor.withOpacity(0.7),
    );
  }

  void _loadWeek() {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    _future = _calendarService.getProfessorWeek(
      weekStart: _toIsoDate(weekStart),
      role: context.read<UserProvider>().role,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  @override
  Widget build(BuildContext context) {
    final base = _startOfWeek(DateTime.now());
    final weekStart = base.add(Duration(days: 7 * _weekOffset));
    final today = DateTime.now();
    final todayIndex = _weekOffset == 0 ? today.weekday - 1 : -1;
    final days = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return (_days[index], _formatDay(date), date);
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
          child: FutureBuilder<List<ProfessorCalendarItemDto>>(
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

              final items = snapshot.data ?? const <ProfessorCalendarItemDto>[];
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
                                              item.studentName,
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

class _ProfessorWeeklyLessonPalette {
  const _ProfessorWeeklyLessonPalette({
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

class _AddHorarioButton extends StatelessWidget {
  const _AddHorarioButton({required this.onTap, required this.config});

  final VoidCallback onTap;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final isOrange = config.roleName == 'Explicador';

    return SizedBox(
      width: CalendarioProfessorLayout.addButtonWidth,
      height: CalendarioProfessorLayout.addButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            CalendarioProfessorLayout.addButtonRadius,
          ),
          color: isOrange ? null : config.primaryColor,
          gradient: isOrange ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CalendarioProfessorColors.addGradientTop,
              CalendarioProfessorColors.addGradientBottom,
            ],
          ) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            CalendarioProfessorLayout.addButtonRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: CalendarioProfessorLayout.addButtonIconSize,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  'Adicionar Horário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: CalendarioProfessorLayout.addButtonFontSize,
                    fontWeight: FontWeight.w500,
                    height:
                        CalendarioProfessorLayout.addButtonLineHeight /
                        CalendarioProfessorLayout.addButtonFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}