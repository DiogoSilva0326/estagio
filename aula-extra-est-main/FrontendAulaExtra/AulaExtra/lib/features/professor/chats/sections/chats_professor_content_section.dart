import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_bubble.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_list_item.dart';
import 'package:aula_extra/features/professor/chats/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// O TEU SERVIÇO REAL TIME QUE ACABÁMOS DE CRIAR
import 'package:aula_extra/core/data/communication/chat_service.dart';

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
  
  // O motor SignalR
  final ChatService _chatService = ChatService();

  String _query = '';
  String? _selectedConversationId; 
  
  late String _meuUserId;
  late String _meuNome;
  List<_ConversationData> _conversations = []; 
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _composerController = TextEditingController();
    
    // 1. Vamos buscar o ID IMEDIATAMENTE (sem atrasos)
    final account = context.read<UserProvider>().account;
    _meuUserId = account?.id ?? "00000000-0000-0000-0000-000000000000";
    _meuNome = account?.fullName ?? "Professor";

    // 2. Ficar à escuta de atualizações
    _chatService.addListener(() {
      if (mounted) setState(() {});
    });

    // 3. Abrir logo o chat do aluno se viermos do perfil dele
    if (widget.initialStudentId != null) {
      _handleSelectConversation(widget.initialStudentId!, widget.initialStudentName ?? "Aluno");
    }
  }

  void _handleSelectConversation(String id, [String studentName = "Aluno"]) { 
    setState(() {
      _selectedConversationId = id;
      
      // Adiciona à lista da esquerda se não existir
      if (!_conversations.any((c) => c.id == id)) {
        _conversations.insert(0, _ConversationData(
          id: id, 
          initials: "AL", 
          name: studentName, 
          status: 'Online', 
          timeLabel: '', 
          preview: '', 
          unreadCount: 0
        ));
      }
    });

    // LIGA O WEBSOCKET PARA ESTA SALA!
    _chatService.connect(
      channelName: 'chat_${_meuUserId}_$id',
      userId: _meuUserId,
      displayName: _meuNome,
    );
  }

  Future<void> _handleSendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    print('🧐 QUEM SOU EU (MEU ID): $_meuUserId');
    print('🧐 COM QUEM ESTOU A FALAR (ID ALUNO): $_selectedConversationId');

    if (!_chatService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ainda a ligar ao chat... tenta novamente.')),
      );
      return;
    }

    _composerController.clear();
    
    // Dispara a mensagem instantânea!
    await _chatService.sendMessage(text);
  }

  @override
  void dispose() {
    _chatService.dispose(); 
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

  @override
  Widget build(BuildContext context) {
    final selectedConversation = _selectedConversation;

    return Container(
      color: ChatsProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 54, right: 23.148, top: 90, bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 28.864),
                child: ProfessorMenuNav(
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
                                    // AQUI PASSAMOS AS MENSAGENS VINDAS DO SERVIDOR EM TEMPO REAL!
                                    realTimeMessages: _chatService.messages,
                                    meuUserId: _meuUserId,
                                    isConnecting: _chatService.isConnecting,
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
    this.unreadCount,
  });

  final String id; 
  final String initials;
  final String name;
  final String status;
  final String timeLabel;
  final String preview;
  final int? unreadCount;

  _ConversationData copyWith({
    String? timeLabel,
    String? preview,
    int? unreadCount,
  }) {
    return _ConversationData(
      id: id,
      initials: initials,
      name: name,
      status: status,
      timeLabel: timeLabel ?? this.timeLabel,
      preview: preview ?? this.preview,
      unreadCount: unreadCount,
    );
  }
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
  final String? selectedConversationId; 
  final ValueChanged<String> onSelectConversation; 

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(1.203),
      child: Column(
        children: [
          Container(
            height: 82.984,
            padding: const EdgeInsets.all(19.243),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203)),
            ),
            child: Container(
              height: 43.296,
              padding: const EdgeInsets.symmetric(horizontal: 14.432),
              decoration: BoxDecoration(
                color: ChatsProfessorColors.searchBackground,
                borderRadius: BorderRadius.circular(12.027),
              ),
              child: TextField(
                controller: controller,
                onChanged: onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Procurar conversa...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.realTimeMessages,
    required this.meuUserId,
    required this.isConnecting,
    required this.composerController,
    required this.onSend,
  });

  final _ConversationData? conversation;
  final List<ChatMessage> realTimeMessages;
  final String meuUserId;
  final bool isConnecting;
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
              border: Border(bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203)),
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
                      ),
                    ),
                    Text(
                      isConnecting ? 'A ligar...' : (c?.status ?? ''),
                      style: TextStyle(
                        color: isConnecting ? Colors.orange : ChatsProfessorColors.mutedText,
                        fontSize: ChatsProfessorFontSizes.conversationStatus,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(19.243),
              child: ListView.separated(
                itemCount: realTimeMessages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 19.243),
                itemBuilder: (context, index) {
                  final m = realTimeMessages[index];
                  final isMine = m.senderId == meuUserId;
                  final hora = '${m.timestamp.toLocal().hour.toString().padLeft(2, '0')}:${m.timestamp.toLocal().minute.toString().padLeft(2, '0')}';
                  
                  return ChatBubble(
                    isMine: isMine,
                    text: m.content,
                    timeLabel: hora,
                    maxWidth: isMine ? 430.47 : 348.294,
                  );
                },
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20.445),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.432),
                        decoration: BoxDecoration(
                          color: ChatsProfessorColors.inputBackground,
                          borderRadius: BorderRadius.circular(14.432),
                        ),
                        child: TextField(
                          controller: composerController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSend(),
                          decoration: const InputDecoration(
                            hintText: 'Escreva uma mensagem...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9.621),
                    // BOTÃO DE ENVIAR CORRIGIDO
                    Material(
                      color: Colors.blue, // Cor sólida para garantir que se vê!
                      borderRadius: BorderRadius.circular(14.432),
                      child: InkWell(
                        onTap: onSend,
                        borderRadius: BorderRadius.circular(14.432),
                        child: const SizedBox(
                          height: 43.296,
                          width: 48.107,
                          child: Center(
                            child: Icon(Icons.send_rounded, size: 20, color: Colors.white),
                          ),
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