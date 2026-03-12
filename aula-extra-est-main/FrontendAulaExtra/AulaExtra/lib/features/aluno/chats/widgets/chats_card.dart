import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:flutter/material.dart';

class ChatsCard extends StatefulWidget {
  const ChatsCard({super.key});

  @override
  State<ChatsCard> createState() => _ChatsCardState();
}

class _ChatsCardState extends State<ChatsCard> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _composerController = TextEditingController();

  String _query = '';
  int _selectedConversationId = 1;

  late final List<_ConversationData> _conversations = [
    _ConversationData(
      id: 1,
      name: 'João Silva',
      initials: 'JS',
      status: 'Online',
      timeLabel: '14:32',
      preview: 'Ótimo trabalho nos exercícios!',
      unreadCount: 2,
      messages: const [
        _MessageData(text: 'Olá! Como estão os exercícios?', time: '14:20', isOutgoing: false),
        _MessageData(text: 'Olá! Estou com uma dúvida no exercício 5', time: '14:25', isOutgoing: true),
        _MessageData(text: 'Claro! Vou te ajudar. Qual é a dúvida?', time: '14:27', isOutgoing: false),
        _MessageData(text: 'Não entendi como aplicar a fórmula', time: '14:30', isOutgoing: true),
        _MessageData(text: 'Ótimo trabalho nos exercícios!', time: '14:32', isOutgoing: false),
      ],
    ),
    _ConversationData(
      id: 2,
      name: 'Maria Santos',
      initials: 'MS',
      status: 'Offline',
      timeLabel: '12:15',
      preview: 'Sobre a próxima aula...',
      messages: const [
        _MessageData(text: 'Sobre a próxima aula...', time: '12:15', isOutgoing: false),
      ],
    ),
    _ConversationData(
      id: 3,
      name: 'Pedro Costa',
      initials: 'PC',
      status: 'Online',
      timeLabel: 'Ontem',
      preview: 'Enviei os materiais',
      unreadCount: 1,
      messages: const [
        _MessageData(text: 'Enviei os materiais', time: 'Ontem', isOutgoing: false),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  _ConversationData? get _selectedConversation {
    try {
      return _conversations.firstWhere((c) => c.id == _selectedConversationId);
    } catch (_) {
      return _conversations.isEmpty ? null : _conversations.first;
    }
  }

  List<_ConversationData> get _filteredConversations {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations.where((c) => c.name.toLowerCase().contains(query)).toList();
  }

  void _handleSelectConversation(int id) {
    setState(() {
      _selectedConversationId = id;
      final idx = _conversations.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      }
    });
  }

  void _handleSendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    setState(() {
      final idx = _conversations.indexWhere((c) => c.id == selected.id);
      if (idx != -1) {
        final updatedMessages = List<_MessageData>.from(_conversations[idx].messages)
          ..add(_MessageData(text: text, time: 'Agora', isOutgoing: true));
        _conversations[idx] = _conversations[idx].copyWith(
          messages: updatedMessages,
          preview: text,
          timeLabel: 'Agora',
        );
      }
    });

    _composerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedConversation;

    return Container(
      padding: const EdgeInsets.all(ChatsConstants.borderWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ChatsConstants.cardRadius),
        border: Border.all(color: ChatsConstants.borderColorSoft, width: ChatsConstants.borderWidth),
        boxShadow: ChatsConstants.shadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const leftWidth = 446.171;
          const minWidth = 980.0;

          final content = Row(
            children: [
              SizedBox(
                width: leftWidth,
                child: _ConversationsPanel(
                  controller: _searchController,
                  onQueryChanged: (value) => setState(() => _query = value),
                  conversations: _filteredConversations,
                  selectedConversationId: selected?.id,
                  onSelectConversation: _handleSelectConversation,
                ),
              ),
              Expanded(
                child: _ChatPanel(
                  conversation: selected,
                  composerController: _composerController,
                  onSend: _handleSendMessage,
                ),
              ),
            ],
          );

          if (constraints.maxWidth < minWidth) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: minWidth),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }
}

class _ConversationsPanel extends StatelessWidget {
  const _ConversationsPanel({
    required this.controller,
    required this.onQueryChanged,
    required this.conversations,
    required this.selectedConversationId,
    required this.onSelectConversation,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final List<_ConversationData> conversations;
  final int? selectedConversationId;
  final ValueChanged<int> onSelectConversation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: ChatsConstants.borderColor, width: ChatsConstants.borderWidth),
        ),
      ),
      child: Column(
        children: [
          _ConversationSearchHeader(controller: controller, onChanged: onQueryChanged),
          Expanded(
            child: _ConversationList(
              conversations: conversations,
              selectedConversationId: selectedConversationId,
              onSelectConversation: onSelectConversation,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationSearchHeader extends StatelessWidget {
  const _ConversationSearchHeader({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98.994,
      padding: const EdgeInsets.fromLTRB(22.309, 22.309, 22.309, 22.309),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ChatsConstants.borderColor, width: ChatsConstants.borderWidth),
        ),
      ),
      child: Container(
        height: 52.983,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(13.943),
          border: Border.all(color: ChatsConstants.borderColor, width: ChatsConstants.borderWidth),
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar conversas...',
            hintStyle: TextStyle(
              fontSize: 19.52,
              fontWeight: FontWeight.w400,
              color: Color(0x800A0A0A),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 22.309, vertical: 11.154),
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.selectedConversationId,
    required this.onSelectConversation,
  });

  final List<_ConversationData> conversations;
  final int? selectedConversationId;
  final ValueChanged<int> onSelectConversation;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final c = conversations[index];
        return _ConversationTile(
          selected: selectedConversationId == c.id,
          name: c.name,
          timeLabel: c.timeLabel,
          preview: c.preview,
          unreadCount: c.unreadCount,
          onTap: () => onSelectConversation(c.id),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.selected,
    required this.name,
    required this.timeLabel,
    required this.preview,
    this.unreadCount,
    required this.onTap,
  });

  final bool selected;
  final String name;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ChatsConstants.selectedConversationBackground : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 112.937,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ChatsConstants.borderColorSoft, width: ChatsConstants.borderWidth),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22.309, vertical: 22.309),
          child: Row(
            children: [
              _AvatarWithBadge(name: name, badge: unreadCount),
              const SizedBox(width: 16.731),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22.309,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF101828),
                              height: 33.463 / 22.309,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 16.731,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6A7282),
                            height: 22.309 / 16.731,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.577),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19.52,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 27.886 / 19.52,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({required this.name, required this.badge});

  final String name;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join();

    return SizedBox(
      width: 66.926,
      height: 66.926,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE5E7EB)),
              child: Center(
                child: SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
              ),
            ),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: -2,
              top: -5.58,
              child: Container(
                width: 27.886,
                height: 27.886,
                decoration: const BoxDecoration(color: ChatsConstants.dangerRed, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 16.731,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 22.309 / 16.731,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.conversation,
    required this.composerController,
    required this.onSend,
  });

  final _ConversationData? conversation;
  final TextEditingController composerController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChatHeader(conversation: conversation),
        Expanded(child: _ChatMessages(messages: conversation?.messages ?? const [])),
        _ChatComposer(controller: composerController, onSend: onSend),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conversation});

  final _ConversationData? conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return Container(
      height: 101.783,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ChatsConstants.borderColor, width: ChatsConstants.borderWidth),
        ),
      ),
      padding: const EdgeInsets.only(left: 22.309),
      child: Row(
        children: [
          SizedBox(
            width: 55.771,
            height: 55.771,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE5E7EB)),
              child: Center(
                child: Text(
                  c?.initials ?? '--',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.731),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c?.name ?? 'Sem conversa selecionada',
                style: const TextStyle(
                  fontSize: 22.309,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF101828),
                  height: 33.463 / 22.309,
                ),
              ),
              Text(
                c?.status ?? '',
                style: const TextStyle(
                  fontSize: 16.731,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A7282),
                  height: 22.309 / 16.731,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatMessages extends StatelessWidget {
  const _ChatMessages({required this.messages});

  final List<_MessageData> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(22.309),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.731),
      itemBuilder: (context, index) {
        final m = messages[index];
        return _ChatMessage(text: m.text, time: m.time, isOutgoing: m.isOutgoing);
      },
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({required this.text, required this.time, this.isOutgoing = false});

  final String text;
  final String time;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    final messageTextColor = isOutgoing ? Colors.white : const Color(0xFF101828);
    final bubbleDecoration = isOutgoing
        ? const BoxDecoration(
            gradient: ChatsConstants.orangeGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.309),
              bottomLeft: Radius.circular(22.309),
              bottomRight: Radius.circular(22.309),
            ),
          )
        : const BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(22.309),
              bottomLeft: Radius.circular(22.309),
              bottomRight: Radius.circular(22.309),
            ),
          );

    return Column(
      crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 349.399),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22.309, 11.154, 22.309, 11.154),
            decoration: bubbleDecoration,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 19.52,
                fontWeight: FontWeight.w400,
                color: messageTextColor,
                height: 27.886 / 19.52,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.577),
        Padding(
          padding: EdgeInsets.only(left: isOutgoing ? 0 : 11.154, right: isOutgoing ? 11.154 : 0),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 16.731,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
              height: 22.309 / 16.731,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ChatsConstants.borderColor, width: ChatsConstants.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22.309, 23.703, 22.309, 22.309),
          child: Row(
            children: [
              _IconSquareButton(icon: Icons.attach_file_rounded, onTap: () {}),
              const SizedBox(width: 16.731),
              _IconSquareButton(icon: Icons.image_outlined, onTap: () {}),
              const SizedBox(width: 16.731),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58.56),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(13.943),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.394),
                  ),
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(
                        fontSize: 22.309,
                        fontWeight: FontWeight.w400,
                        color: Color(0x800A0A0A),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 22.309, vertical: 11.154),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.731),
              _SendSquareButton(onTap: onSend),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.194,
      height: 50.194,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13.943),
        child: InkWell(
          borderRadius: BorderRadius.circular(13.943),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 27.886, color: const Color(0xFF101828)),
          ),
        ),
      ),
    );
  }
}

class _SendSquareButton extends StatelessWidget {
  const _SendSquareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.194,
      height: 50.194,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13.943),
        child: InkWell(
          borderRadius: BorderRadius.circular(13.943),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.943),
              gradient: ChatsConstants.orangeGradient,
            ),
            child: const Center(
              child: Icon(Icons.send_rounded, size: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationData {
  const _ConversationData({
    required this.id,
    required this.name,
    required this.initials,
    required this.status,
    required this.timeLabel,
    required this.preview,
    required this.messages,
    this.unreadCount,
  });

  final int id;
  final String name;
  final String initials;
  final String status;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final List<_MessageData> messages;

  _ConversationData copyWith({
    String? timeLabel,
    String? preview,
    int? unreadCount,
    List<_MessageData>? messages,
  }) {
    return _ConversationData(
      id: id,
      name: name,
      initials: initials,
      status: status,
      timeLabel: timeLabel ?? this.timeLabel,
      preview: preview ?? this.preview,
      unreadCount: unreadCount,
      messages: messages ?? this.messages,
    );
  }
}

class _MessageData {
  const _MessageData({
    required this.text,
    required this.time,
    required this.isOutgoing,
  });

  final String text;
  final String time;
  final bool isOutgoing;
}
