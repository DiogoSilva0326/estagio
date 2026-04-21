import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/calendario/state/student_calendar_refresh_bus.dart';
import 'package:aula_extra/features/aluno/calendario/widgets/pending_lesson_review_dialog.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacao_card.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacoes_filter_pill.dart';
import 'package:flutter/material.dart';

enum NotificacoesFiltro { todas, naoLidas, aulas, tarefas, mensagens }

class NotificacoesContentSection extends StatefulWidget {
  const NotificacoesContentSection({super.key});

  @override
  State<NotificacoesContentSection> createState() =>
      _NotificacoesContentSectionState();
}

class _NotificacoesContentSectionState
    extends State<NotificacoesContentSection> {
  final NotificationsService _notificationsService = NotificationsService();
  final ReservationsCalendarService _calendarService =
      ReservationsCalendarService();
  late Future<void> _loadFuture;
  List<UserNotificationDto> _items = const [];
  NotificacoesFiltro _filtro = NotificacoesFiltro.naoLidas;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadNotifications();
  }

  int get _unreadCount => _items.where((e) => e.unread).length;

  Future<void> _loadNotifications() async {
    final items = await _notificationsService.fetchMyNotifications();
    if (!mounted) return;
    setState(() {
      _items = items;
    });
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;
    final previous = _items;
    setState(() {
      _items = _items
          .map((e) => e.unread ? e.copyWith(isRead: true) : e)
          .toList();
    });
    try {
      await _notificationsService.markAllAsRead();
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível marcar as notificações como lidas.'),
        ),
      );
    }
  }

  Future<void> _markAsRead(String id) async {
    final previous = _items;
    setState(() {
      _items = _items
          .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
          .toList();
    });
    try {
      await _notificationsService.markAsRead(id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível marcar a notificação como lida.'),
        ),
      );
    }
  }

  bool _isPendingStatus(String? status) {
    return isPendingCalendarStatus(status);
  }

  Future<void> _reviewLessonRequest(UserNotificationDto item) async {
    final reservationId = item.reservationId;
    final teacherName = item.teacherName;
    final subject = item.subject;
    final startTime = item.startTime;
    final endTime = item.endTime;

    if (reservationId == null ||
        reservationId.isEmpty ||
        teacherName == null ||
        teacherName.isEmpty ||
        subject == null ||
        subject.isEmpty ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta notificação não tem dados suficientes para revisão.',
          ),
        ),
      );
      return;
    }

    try {
      final status = await _calendarService.getReservationStatus(
        reservationId: reservationId,
      );
      if (!_isPendingStatus(status)) {
        await _markAsRead(item.id);
        if (!mounted) return;
        StudentCalendarRefreshBus.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esta aula já foi decidida e deixou de estar pendente.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      final decision = await showPendingLessonReviewDialog(
        context,
        lesson: PendingLessonReviewData(
          idReservation: reservationId,
          subject: subject,
          teacherName: teacherName,
          startTime: startTime,
          endTime: endTime,
          status: status ?? 'Pending',
        ),
        calendarService: _calendarService,
      );

      if (decision == null || !mounted) return;

      setState(() {
        _items = _items
            .where((current) => current.id != item.id)
            .toList(growable: false);
      });
      StudentCalendarRefreshBus.notifyChanged();
      setState(() {
        _loadFuture = _loadNotifications();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  List<UserNotificationDto> get _filteredItems {
    return _items.where((item) {
      return switch (_filtro) {
        NotificacoesFiltro.todas => true,
        NotificacoesFiltro.naoLidas => item.unread,
        NotificacoesFiltro.aulas => item.kind == UserNotificationKind.aula,
        NotificacoesFiltro.tarefas => item.kind == UserNotificationKind.tarefa,
        NotificacoesFiltro.mensagens =>
          item.kind == UserNotificationKind.mensagem,
      };
    }).toList();
  }

  Widget _buildHeader({required bool isMobile}) {
    final titleStyle = isMobile
        ? NotificacoesConstants.mobileTitleStyle
        : NotificacoesConstants.titleStyle;
    final subtitleStyle = isMobile
        ? NotificacoesConstants.mobileSubtitleStyle
        : NotificacoesConstants.subtitleStyle;
    final actionStyle =
        (isMobile
                ? NotificacoesConstants.mobileActionLinkStyle
                : NotificacoesConstants.actionLinkStyle)
            .copyWith(
              color: _unreadCount == 0 ? const Color(0xFF9CA3AF) : null,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notificações', style: titleStyle),
        SizedBox(height: isMobile ? 8 : 11.243),
        Text('Fique por dentro de tudo que acontece', style: subtitleStyle),
        SizedBox(height: isMobile ? 10 : 18),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: _unreadCount == 0 ? null : _markAllAsRead,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text('Marcar todas como lidas', style: actionStyle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters({required bool isMobile}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          NotificacoesFilterPill(
            label: 'Todas',
            selected: _filtro == NotificacoesFiltro.todas,
            onTap: () => setState(() => _filtro = NotificacoesFiltro.todas),
            isMobile: isMobile,
          ),
          SizedBox(width: isMobile ? 10 : 16.865),
          NotificacoesFilterPill(
            label: 'Não lidas',
            selected: _filtro == NotificacoesFiltro.naoLidas,
            onTap: () => setState(() => _filtro = NotificacoesFiltro.naoLidas),
            isMobile: isMobile,
          ),
          SizedBox(width: isMobile ? 10 : 16.865),
          NotificacoesFilterPill(
            label: 'Aulas',
            selected: _filtro == NotificacoesFiltro.aulas,
            onTap: () => setState(() => _filtro = NotificacoesFiltro.aulas),
            isMobile: isMobile,
          ),
          SizedBox(width: isMobile ? 10 : 16.865),
          NotificacoesFilterPill(
            label: 'Tarefas',
            selected: _filtro == NotificacoesFiltro.tarefas,
            onTap: () => setState(() => _filtro = NotificacoesFiltro.tarefas),
            isMobile: isMobile,
          ),
          SizedBox(width: isMobile ? 10 : 16.865),
          NotificacoesFilterPill(
            label: 'Mensagens',
            selected: _filtro == NotificacoesFiltro.mensagens,
            onTap: () => setState(() => _filtro = NotificacoesFiltro.mensagens),
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isMobile
              ? NotificacoesConstants.mobileCardRadius
              : NotificacoesConstants.cardRadius,
        ),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: NotificacoesConstants.borderWidth,
        ),
        boxShadow: NotificacoesConstants.cardShadow,
      ),
      child: Text(
        'Não existem notificações para este filtro.',
        style: TextStyle(
          fontSize: isMobile ? 14 : 18,
          color: const Color(0xFF4A5565),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildNotificationList({required bool isMobile}) {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState(isMobile: isMobile);
    }

    return Column(
      children: List.generate(_filteredItems.length, (index) {
        final item = _filteredItems[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _filteredItems.length - 1
                ? 0
                : (isMobile ? NotificacoesConstants.mobileCardSpacing : 16.865),
          ),
          child: NotificacaoCard(
            item: item,
            isMobile: isMobile,
            onPrimaryAction: item.isLessonReviewRequest
                ? () => _reviewLessonRequest(item)
                : null,
            primaryActionLabel: item.isLessonReviewRequest
                ? 'Rever aula'
                : null,
            onMarkAsRead: item.unread ? () => _markAsRead(item.id) : null,
          ),
        );
      }),
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isMobile: false),
        const SizedBox(height: 44),
        _UnreadSummaryCard(count: _unreadCount),
        const SizedBox(height: 33),
        _buildFilters(isMobile: false),
        const SizedBox(height: 33),
        _buildNotificationList(isMobile: false),
      ],
    );
  }

  Widget _buildMobileListContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotificacoesConstants.mobileHorizontalPadding,
        vertical: NotificacoesConstants.mobileVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile: true),
          const SizedBox(height: NotificacoesConstants.mobileSectionSpacing),
          _UnreadSummaryCard(count: _unreadCount, isMobile: true),
          const SizedBox(height: NotificacoesConstants.mobileSectionSpacing),
          _buildFilters(isMobile: true),
          const SizedBox(height: NotificacoesConstants.mobileSectionSpacing),
          _buildNotificationList(isMobile: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError && _items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NotificacoesConstants.mobileHorizontalPadding,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificações',
                    style: NotificacoesConstants.mobileTitleStyle,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadFuture = _loadNotifications();
                      });
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return _buildMobileListContent();
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotificacoesConstants.horizontalPadding,
        vertical: NotificacoesConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlunoMenuNav(selectedIndex: 8, notificationCount: _unreadCount),
          const SizedBox(width: 40),
          Expanded(
            child: FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError && _items.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notificações',
                        style: NotificacoesConstants.titleStyle,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadFuture = _loadNotifications();
                          });
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  );
                }

                return _buildListContent();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadSummaryCard extends StatelessWidget {
  const _UnreadSummaryCard({required this.count, this.isMobile = false});

  final int count;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: isMobile
          ? const EdgeInsets.fromLTRB(18, 18, 18, 18)
          : const EdgeInsets.fromLTRB(35.135, 35.135, 35.135, 35.135),
      decoration: BoxDecoration(
        gradient: NotificacoesConstants.unreadSummaryGradient,
        borderRadius: BorderRadius.circular(
          isMobile
              ? NotificacoesConstants.mobileCardRadius
              : NotificacoesConstants.cardRadius,
        ),
        border: Border.all(
          color: NotificacoesConstants.unreadSummaryBorderColor,
          width: NotificacoesConstants.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile
                ? NotificacoesConstants.mobileSummaryBadgeSize
                : 67.459,
            height: isMobile
                ? NotificacoesConstants.mobileSummaryBadgeSize
                : 67.459,
            decoration: const BoxDecoration(
              gradient: NotificacoesConstants.iconOrangeGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: NotificacoesConstants.mobileSummaryIconSize,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16.865),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 33.73,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFCA3500),
                  height: isMobile ? 1.15 : 44.973 / 33.73,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Notificações não lidas',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 19.676,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF54900),
                  height: isMobile ? 1.35 : 28.108 / 19.676,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
