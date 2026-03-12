import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_mock_data.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacao_card.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacoes_filter_pill.dart';
import 'package:flutter/material.dart';

enum NotificacoesFiltro { todas, naoLidas, aulas, tarefas, mensagens }

class NotificacoesContentSection extends StatefulWidget {
  const NotificacoesContentSection({super.key});

  @override
  State<NotificacoesContentSection> createState() => _NotificacoesContentSectionState();
}

class _NotificacoesContentSectionState extends State<NotificacoesContentSection> {
  late List<NotificacaoItem> _items;
  NotificacoesFiltro _filtro = NotificacoesFiltro.todas;

  @override
  void initState() {
    super.initState();
    _items = [...NotificacoesMockData.items];
  }

  int get _unreadCount => _items.where((e) => e.unread).length;

  void _markAllAsRead() {
    setState(() {
      _items = _items.map((e) => e.unread ? e.copyWith(unread: false) : e).toList();
    });
  }

  void _markAsRead(String id) {
    setState(() {
      _items = _items.map((e) => e.id == id ? e.copyWith(unread: false) : e).toList();
    });
  }

  List<NotificacaoItem> get _filteredItems {
    return _items.where((item) {
      return switch (_filtro) {
        NotificacoesFiltro.todas => true,
        NotificacoesFiltro.naoLidas => item.unread,
        NotificacoesFiltro.aulas => item.tipo == NotificacaoTipo.aula,
        NotificacoesFiltro.tarefas => item.tipo == NotificacaoTipo.tarefa,
        NotificacoesFiltro.mensagens => item.tipo == NotificacaoTipo.mensagem,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotificacoesConstants.horizontalPadding,
        vertical: NotificacoesConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlunoMenuNav(selectedIndex: 9, notificationCount: _unreadCount),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Notificações', style: NotificacoesConstants.titleStyle),
                        SizedBox(height: 11.243),
                        Text('Fique por dentro de tudo que acontece', style: NotificacoesConstants.subtitleStyle),
                      ],
                    ),
                    InkWell(
                      onTap: _unreadCount == 0 ? null : _markAllAsRead,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Text('Marcar todas como lidas', style: NotificacoesConstants.actionLinkStyle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                _UnreadSummaryCard(count: _unreadCount),
                const SizedBox(height: 33),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      NotificacoesFilterPill(
                        label: 'Todas',
                        selected: _filtro == NotificacoesFiltro.todas,
                        onTap: () => setState(() => _filtro = NotificacoesFiltro.todas),
                      ),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(
                        label: 'Não lidas',
                        selected: _filtro == NotificacoesFiltro.naoLidas,
                        onTap: () => setState(() => _filtro = NotificacoesFiltro.naoLidas),
                      ),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(
                        label: 'Aulas',
                        selected: _filtro == NotificacoesFiltro.aulas,
                        onTap: () => setState(() => _filtro = NotificacoesFiltro.aulas),
                      ),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(
                        label: 'Tarefas',
                        selected: _filtro == NotificacoesFiltro.tarefas,
                        onTap: () => setState(() => _filtro = NotificacoesFiltro.tarefas),
                      ),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(
                        label: 'Mensagens',
                        selected: _filtro == NotificacoesFiltro.mensagens,
                        onTap: () => setState(() => _filtro = NotificacoesFiltro.mensagens),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 33),
                ...List.generate(_filteredItems.length, (index) {
                  final item = _filteredItems[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == _filteredItems.length - 1 ? 0 : 16.865),
                    child: NotificacaoCard(
                      item: item,
                      onMarkAsRead: item.unread ? () => _markAsRead(item.id) : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadSummaryCard extends StatelessWidget {
  const _UnreadSummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(35.135, 35.135, 35.135, 35.135),
      decoration: BoxDecoration(
        gradient: NotificacoesConstants.unreadSummaryGradient,
        borderRadius: BorderRadius.circular(NotificacoesConstants.cardRadius),
        border: Border.all(
          color: NotificacoesConstants.unreadSummaryBorderColor,
          width: NotificacoesConstants.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 67.459,
            height: 67.459,
            decoration: const BoxDecoration(
              gradient: NotificacoesConstants.iconOrangeGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 33.73),
          ),
          const SizedBox(width: 16.865),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 33.73,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFCA3500),
                  height: 44.973 / 33.73,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Notificações não lidas',
                style: TextStyle(
                  fontSize: 19.676,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFF54900),
                  height: 28.108 / 19.676,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
