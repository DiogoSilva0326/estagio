import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacao_card.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacoes_filter_pill.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

enum NotificacoesProfessorFiltro { todas, naoLidas, aulas, tarefas, mensagens }

class NotificacoesProfessorContentSection extends StatefulWidget {
  const NotificacoesProfessorContentSection({super.key});

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

  Future<void> _handleCancellationDecision(UserNotificationDto item) async {
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => _CancellationDecisionDialog(item: item),
    );

    if (decision == null) return;
    await _applyCancellationDecision(item, forgivePenalty: decision);
  }

  Future<void> _applyCancellationDecision(
    UserNotificationDto item, {
    required bool forgivePenalty,
  }) async {
    final studentUserId = item.studentUserId?.trim();
    if (studentUserId == null || studentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar o aluno desta notificação.',
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
            ? 'O professor aceitou a tua justificação e a penalidade foi perdoada.'
            : 'O professor não aceitou a tua justificação e a penalidade da aula foi mantida.',
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

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          NotificacoesFilterPill(
            label: 'Todas',
            selected: _filtro == NotificacoesProfessorFiltro.todas,
            onTap: () =>
                setState(() => _filtro = NotificacoesProfessorFiltro.todas),
          ),
          const SizedBox(width: 16.865),
          NotificacoesFilterPill(
            label: 'Não lidas',
            selected: _filtro == NotificacoesProfessorFiltro.naoLidas,
            onTap: () =>
                setState(() => _filtro = NotificacoesProfessorFiltro.naoLidas),
          ),
          const SizedBox(width: 16.865),
          NotificacoesFilterPill(
            label: 'Aulas',
            selected: _filtro == NotificacoesProfessorFiltro.aulas,
            onTap: () =>
                setState(() => _filtro = NotificacoesProfessorFiltro.aulas),
          ),
          const SizedBox(width: 16.865),
          NotificacoesFilterPill(
            label: 'Tarefas',
            selected: _filtro == NotificacoesProfessorFiltro.tarefas,
            onTap: () =>
                setState(() => _filtro = NotificacoesProfessorFiltro.tarefas),
          ),
          const SizedBox(width: 16.865),
          NotificacoesFilterPill(
            label: 'Mensagens',
            selected: _filtro == NotificacoesProfessorFiltro.mensagens,
            onTap: () =>
                setState(() => _filtro = NotificacoesProfessorFiltro.mensagens),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          NotificacoesProfessorLayout.cardRadius,
        ),
        border: Border.all(
          color: const Color(0xFFFFE2CC),
          width: NotificacoesProfessorLayout.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: NotificacoesProfessorColors.unreadAccent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_unreadCount',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: NotificacoesProfessorColors.title,
                ),
              ),
              const Text(
                'Notificações não lidas',
                style: TextStyle(
                  fontSize: 16,
                  color: NotificacoesProfessorColors.subtitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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

  Widget _buildContent(TextStyle titleStyle, TextStyle subtitleStyle) {
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
                    'Você tem $_unreadCount notificações não lidas',
                    style: subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _MarkAllAsReadButton(
              enabled: _unreadCount > 0,
              onTap: _markAllAsRead,
            ),
          ],
        ),
        const SizedBox(height: 28.737),
        _buildUnreadSummaryCard(),
        const SizedBox(height: 28.737),
        _buildFilters(),
        const SizedBox(height: 28.737),
        if (_filteredItems.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(_filteredItems.length, (index) {
            final item = _filteredItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _filteredItems.length - 1
                    ? 0
                    : NotificacoesProfessorLayout.cardsGap,
              ),
              child: NotificacaoCard(
                item: item,
                onPrimaryAction:
                    item.isJustifiedCancellationRequest &&
                        !item.decisionMade &&
                        _processingNotificationId != item.id
                    ? () => _handleCancellationDecision(item)
                    : null,
                primaryActionLabel:
                    item.isJustifiedCancellationRequest && !item.decisionMade
                    ? 'Analisar justificação'
                    : null,
                onMarkAsRead: item.unread ? () => _markAsRead(item.id) : null,
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              ProfessorMenuNav(notificationCount: _unreadCount),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    0,
                  ),
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
                            Text('Notificações', style: titleStyle),
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

                      return _buildContent(titleStyle, subtitleStyle);
                    },
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

class _CancellationDecisionDialog extends StatelessWidget {
  const _CancellationDecisionDialog({required this.item});

  final UserNotificationDto item;

  @override
  Widget build(BuildContext context) {
    final student = item.studentName?.trim().isNotEmpty == true
        ? item.studentName!.trim()
        : 'Aluno';
    final justification = item.justification?.trim().isNotEmpty == true
        ? item.justification!.trim()
        : 'Sem justificação fornecida.';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.feedback_outlined, color: Color(0xFFFF6B00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Justificação de $student',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O aluno cancelou a aula a menos de 24h e deixou o seguinte motivo:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Text(
              '“$justification”',
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFF344054),
              ),
            ),
          ),
          if (item.decisionMade) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.decision == 'Perdoada'
                    ? const Color(0xFFE6F4EA)
                    : const Color(0xFFFEE4E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    item.decision == 'Perdoada'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: item.decision == 'Perdoada'
                        ? const Color(0xFF00C950)
                        : const Color(0xFFF04438),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.decision == 'Perdoada'
                          ? 'Decisão: penalidade perdoada'
                          : 'Decisão: penalidade mantida',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.decision == 'Perdoada'
                            ? const Color(0xFF00C950)
                            : const Color(0xFFF04438),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'O que pretendes fazer em relação à penalidade?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
      actions: item.decisionMade
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ]
          : [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF04438),
                  side: const BorderSide(color: Color(0xFFF04438)),
                ),
                child: const Text('Manter penalidade'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C950),
                ),
                child: const Text(
                  'Perdoar falta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
    );
  }
}

class _MarkAllAsReadButton extends StatelessWidget {
  const _MarkAllAsReadButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NotificacoesProfessorLayout.markAllButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            NotificacoesProfessorLayout.markAllButtonRadius,
          ),
          border: Border.all(
            color: NotificacoesProfessorColors.buttonBorder,
            width: NotificacoesProfessorLayout.markAllButtonBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(
            NotificacoesProfessorLayout.markAllButtonRadius,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.355),
            child: Center(
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(
                  color: enabled
                      ? NotificacoesProfessorColors.buttonText
                      : const Color(0xFF9CA3AF),
                  fontSize: NotificacoesProfessorLayout.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  height:
                      NotificacoesProfessorLayout.bodyLineHeight /
                      NotificacoesProfessorLayout.bodyFontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
