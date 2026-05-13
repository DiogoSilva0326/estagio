import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacao_card.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacoes_filter_pill.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_filters.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/notificacoes_professor_cancellation_dialog.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/notificacoes_professor_mark_all_button.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/notificacoes_professor_mobile_header_block.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/notificacoes_professor_unread_summary_card.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class NotificacoesProfessorContentSection extends StatefulWidget {
  const NotificacoesProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<NotificacoesProfessorContentSection> createState() =>
      _NotificacoesProfessorContentSectionState();
}

class _NotificacoesProfessorContentSectionState
    extends State<NotificacoesProfessorContentSection> {
  final NotificationsService _notificationsService = NotificationsService();
  late Future<void> _loadFuture;
  List<UserNotificationDto> _items = const [];
  NotificacoesProfessorFiltro _filtro = NotificacoesProfessorFiltro.naoLidas;
  String? _processingNotificationId;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadNotifications();
  }

  int get _unreadCount => _items.where((item) => item.unread).length;

  List<UserNotificationDto> get _filteredItems {
    return _items.where((item) {
      return switch (_filtro) {
        NotificacoesProfessorFiltro.todas => true,
        NotificacoesProfessorFiltro.naoLidas => item.unread,
        NotificacoesProfessorFiltro.aulas =>
          item.kind == UserNotificationKind.aula,
        NotificacoesProfessorFiltro.tarefas =>
          item.kind == UserNotificationKind.tarefa,
        NotificacoesProfessorFiltro.mensagens =>
          item.kind == UserNotificationKind.mensagem,
      };
    }).toList();
  }

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
          .map((item) => item.unread ? item.copyWith(isRead: true) : item)
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
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
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

  Future<void> _handleCancellationDecision(
      UserNotificationDto item, TeachingRoleConfig config) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => NotificacoesProfessorCancellationDialog(
        item: item,
        config: config,
      ),
    );

    if (decision == null) return;
    await _applyCancellationDecision(item,
        forgivePenalty: decision, config: config);
  }

  Future<void> _applyCancellationDecision(
    UserNotificationDto item, {
    required bool forgivePenalty,
    required TeachingRoleConfig config,
  }) async {
    final studentUserId = item.studentUserId?.trim();
    
    final studentLabel = config.studentsLabel.toLowerCase().replaceAll('meus ', '').replaceAll('s', '');

    if (studentUserId == null || studentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível identificar o $studentLabel desta notificação.',
          ),
        ),
      );
      return;
    }

    setState(() => _processingNotificationId = item.id);

    try {
      await _notificationsService.createNotification(
        idUser: studentUserId,
        type: forgivePenalty ? 'Falta Perdoada' : 'Justificação Recusada',
        message: forgivePenalty
            ? 'O ${config.roleName.toLowerCase()} aceitou a tua justificação e a penalidade foi perdoada.'
            : 'O ${config.roleName.toLowerCase()} não aceitou a tua justificação e a penalidade da ${config.sessionsLabel} foi mantida.',
      );

      await _notificationsService.markAsRead(item.id);

      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (currentItem) => currentItem.id == item.id
                  ? currentItem.copyWith(
                      isRead: true,
                      lastUpdate: DateTime.now(),
                    )
                  : currentItem,
            )
            .toList(growable: false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            forgivePenalty
                ? 'Falta perdoada com sucesso.'
                : 'Justificação recusada com sucesso.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _processingNotificationId = null);
      }
    }
  }

  Widget _buildFilters(TeachingRoleConfig config) {
    final filters = NotificacoesProfessorFiltro.values;
    final spacing = widget.isMobile ? 10.0 : 16.865;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          
          String label = filter.label;
          if (filter == NotificacoesProfessorFiltro.aulas) {
            final text = config.sessionsLabel;
            label = text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;
          }

          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : spacing,
            ),
            child: NotificacoesFilterPill(
              label: label,
              selected: _filtro == filter,
              isMobile: widget.isMobile,
              activeColor: config.primaryColor, 
              onTap: () => setState(() => _filtro = filter),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUnreadSummaryCard(TeachingRoleConfig config) {
    return NotificacoesProfessorUnreadSummaryCard(
      unreadCount: _unreadCount,
      isMobile: widget.isMobile,
      config: config,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          NotificacoesProfessorLayout.cardRadius,
        ),
        border: Border.all(
          color: NotificacoesProfessorColors.readBorder,
          width: NotificacoesProfessorLayout.cardBorderWidth,
        ),
      ),
      child: const Text(
        'Não existem notificações para este filtro.',
        style: TextStyle(
          fontSize: 18,
          color: NotificacoesProfessorColors.subtitle,
        ),
      ),
    );
  }

  Widget _buildNotificationsList(TeachingRoleConfig config) {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: List.generate(_filteredItems.length, (index) {
        final item = _filteredItems[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _filteredItems.length - 1
                ? 0
                : widget.isMobile
                ? 14
                : NotificacoesProfessorLayout.cardsGap,
          ),
          child: NotificacaoCard(
            item: item,
            isMobile: widget.isMobile,
            onPrimaryAction:
                item.isJustifiedCancellationRequest &&
                    !item.decisionMade &&
                    _processingNotificationId != item.id
                ? () => _handleCancellationDecision(item, config)
                : null,
            primaryActionLabel:
                item.isJustifiedCancellationRequest && !item.decisionMade
                ? 'Analisar justificação'
                : null,
            onMarkAsRead: item.unread ? () => _markAsRead(item.id) : null,
          ),
        );
      }),
    );
  }

  Widget _buildDesktopContent(TextStyle titleStyle, TextStyle subtitleStyle, TeachingRoleConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: NotificacoesProfessorLayout.titleLineHeight,
                    child: Text('Notificações', style: titleStyle),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tem $_unreadCount notificações não lidas',
                    style: subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            NotificacoesProfessorMarkAllButton(
              enabled: _unreadCount > 0,
              onTap: _markAllAsRead,
              config: config,
            ),
          ],
        ),
        const SizedBox(height: 28.737),
        _buildUnreadSummaryCard(config),
        const SizedBox(height: 28.737),
        _buildFilters(config),
        const SizedBox(height: 28.737),
        _buildNotificationsList(config),
      ],
    );
  }

  Widget _buildMobileContent(TeachingRoleConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificacoesProfessorMobileHeaderBlock(
          unreadCount: _unreadCount,
          canMarkAll: _unreadCount > 0,
          onMarkAllTap: _markAllAsRead,
          config: config,
        ),
        const SizedBox(height: 20),
        _buildUnreadSummaryCard(config),
        const SizedBox(height: 18),
        _buildFilters(config),
        const SizedBox(height: 18),
        _buildNotificationsList(config),
      ],
    );
  }

  Widget _buildErrorState({TextStyle? titleStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isMobile)
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          )
        else if (titleStyle != null)
          Text('Notificações', style: titleStyle),
        const SizedBox(height: 16),
        const Text(
          'Não foi possível carregar as notificações.',
          style: TextStyle(color: Color(0xFFB42318), fontSize: 16),
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

  Widget _buildAsyncContent({TextStyle? titleStyle, TextStyle? subtitleStyle, required TeachingRoleConfig config}) {
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
          return _buildErrorState(titleStyle: titleStyle);
        }

        if (widget.isMobile) {
          return _buildMobileContent(config);
        }

        return _buildDesktopContent(titleStyle!, subtitleStyle!, config);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final titleStyle = TextStyle(
      color: NotificacoesProfessorColors.title,
      fontSize: NotificacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height:
          NotificacoesProfessorLayout.titleLineHeight /
          NotificacoesProfessorLayout.titleFontSize,
    );

    final subtitleStyle = TextStyle(
      color: NotificacoesProfessorColors.subtitle,
      fontSize: NotificacoesProfessorLayout.subtitleFontSize,
      fontWeight: FontWeight.w400,
      height:
          NotificacoesProfessorLayout.subtitleLineHeight /
          NotificacoesProfessorLayout.subtitleFontSize,
    );

    if (widget.isMobile) {
      return Container(
        width: double.infinity,
        color: const Color(0xFFFFFBF7),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: _buildAsyncContent(config: config),
      );
    }

    return Container(
      color: NotificacoesProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: NotificacoesProfessorLayout.pageLeftPadding,
            right: NotificacoesProfessorLayout.pageRightPadding,
            top: NotificacoesProfessorLayout.pageTopPadding,
            bottom: NotificacoesProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfessorMenuNav(
                selectedIndex: 11,
                notificationCount: _unreadCount,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    0,
                  ),
                  child: _buildAsyncContent(
                    titleStyle: titleStyle,
                    subtitleStyle: subtitleStyle,
                    config: config,
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