import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_bubble.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_list_item.dart';
import 'package:aula_extra/features/professor/chats/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class ChatsProfessorContentSection extends StatefulWidget {
  final String? initialStudentId; 
  final String? initialStudentName;

  const ChatsProfessorContentSection({
    super.key, 
    this.initialStudentId, 
    this.initialStudentName,
  });

  @override
  State<ChatsProfessorContentSection> createState() => _ChatsProfessorContentSectionState();
}

class _ChatsProfessorContentSectionState extends State<ChatsProfessorContentSection> {
  late final TextEditingController _searchController;
  late final TextEditingController _composerController;

  String _query = '';
  int? _selectedConversationId;
  
  late List<_ConversationData> _conversations; 
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _composerController = TextEditingController();
    
    _conversations = [
      const _ConversationData(id: 1, initials: 'JD', name: 'João Dias', status: 'Online', timeLabel: 'Agora', preview: 'Ok, vou rever esses exercícios.', messages: []),
      const _ConversationData(id: 2, initials: 'MS', name: 'Maria Silva', status: 'Offline', timeLabel: '14:30', preview: 'Obrigada pela aula de hoje!', unreadCount: 2, messages: []),
    ];

    _carregarOuCriarChat();
  }

  Future<void> _carregarOuCriarChat() async {
    if (widget.initialStudentId != null) {
      final studentIdStr = widget.initialStudentId!;
      final studentName = widget.initialStudentName ?? 'Aluno';

      String initials = 'AL';
      if (studentName.isNotEmpty) {
        final parts = studentName.trim().split(' ');
        if (parts.length > 1) {
          initials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
        } else {
          initials = studentName.substring(0, studentName.length >= 2 ? 2 : 1).toUpperCase();
        }
      }

      final studentIdInt = int.tryParse(studentIdStr) ?? studentIdStr.hashCode;
      
      setState(() {
        final index = _conversations.indexWhere((c) => c.id == studentIdInt);
        
        if (index != -1) {
          _selectedConversationId = _conversations[index].id;
        } else {
          final newChat = _ConversationData(
            id: studentIdInt,
            initials: initials, 
            name: studentName, 
            status: 'Online',
            timeLabel: 'Agora',
            preview: 'Inicia a conversa...',
            messages: const [],
          );
          _conversations.insert(0, newChat); 
          _selectedConversationId = studentIdInt; 
        }
      });
    }
  }

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
          ..add(_MessageData(isMine: true, text: text, timeLabel: 'Agora'));
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
    final selectedConversation = _selectedConversation;

    return Container(
      color: ChatsProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 54,
            right: 23.148,
            top: 90,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 28.864),
                child: const ProfessorMenuNav(
                  selectedIndex: 4,
                  notificationCount: 2,
                  aulasEstaSemana: 8,
                  ganhosPendentes: '150€',
                  alunosAtivos: 12,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28.864, 28.864, 28.864, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 43.296,
                        child: Text(
                          'Chats',
                          style: TextStyle(
                            color: ChatsProfessorColors.title,
                            fontSize: ChatsProfessorFontSizes.title,
                            fontWeight: FontWeight.w700,
                            height: 43.296 / ChatsProfessorFontSizes.title,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28.864),
                      SizedBox(
                        height: 797.368,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const leftWidth = 313.492;
                            const gap = 28.868;
                            const rightWidth = 655.857;
                            const minWidth = leftWidth + gap + rightWidth;

                            final content = Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: leftWidth,
                                  child: _ChatListCard(
                                    controller: _searchController,
                                    onQueryChanged: (value) => setState(() => _query = value),
                                    conversations: _filteredConversations,
                                    selectedConversationId: selectedConversation?.id,
                                    onSelectConversation: _handleSelectConversation,
                                  ),
                                ),
                                const SizedBox(width: gap),
                                SizedBox(
                                  width: rightWidth,
                                  child: _ConversationCard(
                                    conversation: selectedConversation,
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
                      ),
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

class _ConversationData {
  const _ConversationData({
    required this.id,
    required this.initials,
    required this.name,
    required this.status,
    required this.timeLabel,
    required this.preview,
    required this.messages,
    this.unreadCount,
  });

  final int id;
  final String initials;
  final String name;
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
      initials: initials,
      name: name,
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
    required this.isMine,
    required this.text,
    required this.timeLabel,
  });

  final bool isMine;
  final String text;
  final String timeLabel;
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChatsProfessorColors.cardBackground,
        borderRadius: BorderRadius.circular(19.243),
        border: Border.all(color: ChatsProfessorColors.cardBorder, width: 1.203),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 4.811),
            blurRadius: 7.216,
            spreadRadius: -1.203,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 2.405),
            blurRadius: 4.811,
            spreadRadius: -2.405,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _ChatListCard extends StatelessWidget {
  const _ChatListCard({
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
    return _CardShell(
      padding: const EdgeInsets.all(1.203),
      child: Column(
        children: [
          Container(
            height: 82.984,
            padding: const EdgeInsets.only(
              left: 19.243,
              right: 19.243,
              top: 19.243,
              bottom: 1.203,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203),
              ),
            ),
            child: Container(
              height: 43.296,
              padding: const EdgeInsets.symmetric(horizontal: 14.432, vertical: 4.811),
              decoration: BoxDecoration(
                color: ChatsProfessorColors.searchBackground,
                borderRadius: BorderRadius.circular(12.027),
                border: Border.all(color: Colors.transparent, width: 1.203),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Procurar conversa...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  color: ChatsProfessorColors.title,
                  fontSize: ChatsProfessorFontSizes.searchHint,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19.243),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final c = conversations[index];
                  return ChatListItem(
                    initials: c.initials,
                    name: c.name,
                    timeLabel: c.timeLabel,
                    preview: c.preview,
                    unreadCount: c.unreadCount,
                    selected: selectedConversationId == c.id,
                    onTap: () => onSelectConversation(c.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.composerController,
    required this.onSend,
  });

  final _ConversationData? conversation;
  final TextEditingController composerController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = conversation;

    return _CardShell(
      padding: const EdgeInsets.all(1.203),
      child: Column(
        children: [
          Container(
            height: 91.403,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203),
              ),
            ),
            padding: const EdgeInsets.only(left: 19.243, bottom: 1.203),
            child: Row(
              children: [
                ChatAvatar(initials: c?.initials ?? '--', size: 48.107),
                const SizedBox(width: 14.432),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c?.name ?? 'Sem conversa selecionada',
                      style: const TextStyle(
                        color: ChatsProfessorColors.title,
                        fontSize: ChatsProfessorFontSizes.conversationName,
                        fontWeight: FontWeight.w500,
                        height: 32.472 / ChatsProfessorFontSizes.conversationName,
                      ),
                    ),
                    Text(
                      c?.status ?? '',
                      style: const TextStyle(
                        color: ChatsProfessorColors.mutedText,
                        fontSize: ChatsProfessorFontSizes.conversationStatus,
                        fontWeight: FontWeight.w400,
                        height: 19.243 / ChatsProfessorFontSizes.conversationStatus,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(19.243, 19.243, 19.243, 0),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: c?.messages.length ?? 0,
                separatorBuilder: (context, index) => const SizedBox(height: 19.243),
                itemBuilder: (context, index) {
                  final m = c!.messages[index];
                  return ChatBubble(
                    isMine: m.isMine,
                    text: m.text,
                    timeLabel: m.timeLabel,
                    maxWidth: m.isMine ? 430.47 : 348.294,
                  );
                },
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 19.243, right: 19.243, top: 20.445, bottom: 20.445),
                child: Row(
                  children: [
                    _IconButton(icon: Icons.attach_file_rounded, onTap: () {}),
                    const SizedBox(width: 9.621),
                    _IconButton(icon: Icons.image_rounded, onTap: () {}),
                    const SizedBox(width: 9.621),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 43.296),
                        padding: const EdgeInsets.symmetric(horizontal: 14.432, vertical: 4.811),
                        decoration: BoxDecoration(
                          color: ChatsProfessorColors.inputBackground,
                          borderRadius: BorderRadius.circular(14.432),
                          border: Border.all(color: Colors.transparent, width: 1.203),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: composerController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSend(),
                          decoration: const InputDecoration(
                            hintText: 'Escreva uma mensagem...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: ChatsProfessorColors.title,
                            fontSize: ChatsProfessorFontSizes.searchHint,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9.621),
                    InkWell(
                      onTap: onSend,
                      borderRadius: BorderRadius.circular(14.432),
                      child: Ink(
                        height: 43.296,
                        width: 48.107,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.432),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ChatsProfessorColors.rightBubbleGradientStart,
                              ChatsProfessorColors.rightBubbleGradientEnd,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.send_rounded, size: 19.243, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 43.296,
      height: 43.296,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.027),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.027),
          child: Center(
            child: Icon(icon, size: 24.053, color: ChatsProfessorColors.mutedText),
          ),
        ),
      ),
    );
  }
}