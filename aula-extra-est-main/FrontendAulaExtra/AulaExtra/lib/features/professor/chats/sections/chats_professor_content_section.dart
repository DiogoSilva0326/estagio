import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_bubble.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_list_item.dart';
import 'package:aula_extra/features/professor/chats/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatsProfessorContentSection extends StatefulWidget {
  final String? initialStudentId; 
  final String? initialStudentName;
  const ChatsProfessorContentSection({super.key, this.initialStudentId, this.initialStudentName});

  @override
  State<ChatsProfessorContentSection> createState() => _ChatsProfessorContentSectionState();
}

class _ChatsProfessorContentSectionState extends State<ChatsProfessorContentSection> {
  late final TextEditingController _searchController;
  late final TextEditingController _composerController;
  String _query = '';
  int? _selectedConversationId;
  String? _myUserId;
  List<_ConversationData> _conversations = []; 
  bool _isLoading = false;

  HubConnection? _hubConnection;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _composerController = TextEditingController();
    _carregarTudoDaAPI();
  }

  Future<void> _iniciarSignalR(String myId) async {
    try {
      final baseUrl = ApiConfig.uri('/chathub').toString(); 
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(baseUrl)
          .withAutomaticReconnect()
          .build();

      _hubConnection?.on("MessageReceived", _handleNovaMensagemRecebida);

      await _hubConnection?.start();
      debugPrint('SignalR Conectado com sucesso (Professor)!');

      await _hubConnection?.invoke("JoinMyPersonalRoom", args: [myId]);
      
    } catch (e) {
      debugPrint('Erro a conectar ao SignalR: $e');
    }
  }

  void _handleNovaMensagemRecebida(List<Object?>? args) {
    if (args == null || args.length < 3) return;

    final senderId = args[0].toString();
    final content = args[1].toString();
    final timeStr = args[2].toString(); 

    if (senderId == _myUserId) return;

    String timeLabel = 'Agora';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      timeLabel = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    setState(() {
      final idx = _conversations.indexWhere((c) => c.backendGuid == senderId);
      
      if (idx != -1) {
        final updatedMessages = List<_MessageData>.from(_conversations[idx].messages)
          ..add(_MessageData(isMine: false, text: content, timeLabel: timeLabel)); // No professor chamaste isMine
        
        _conversations[idx] = _conversations[idx].copyWith(
          messages: updatedMessages, 
          preview: content, 
          timeLabel: timeLabel,
          unreadCount: (_selectedConversationId == _conversations[idx].id) ? 0 : (_conversations[idx].unreadCount ?? 0) + 1
        );
      } else {
        _carregarTudoDaAPI();
      }
    });
  }

  String _extrairIdDoToken(String token) {
    try {
      final payloadBase64 = token.split('.')[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      return payloadMap['sub']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<Map<String, String>> _buscarDadosAluno(String userId, String token) async {
    try {
      final response = await http.get(
        ApiConfig.uri('/api/Users/$userId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        String initials = 'AL';
        if (name.isNotEmpty) {
          final parts = name.split(' ');
          initials = parts.length > 1 
              ? '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase() 
              : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
        }
        return {'name': name.isEmpty ? 'Aluno Desconhecido' : name, 'initials': initials};
      }
    } catch (_) {}
    return {'name': 'Aluno', 'initials': 'AL'};
  }

  Future<void> _carregarTudoDaAPI() async {
    setState(() => _isLoading = true);
    try {
      final token = await TokenStorage().loadToken() ?? '';
      _myUserId = _extrairIdDoToken(token);
      
      final response = await http.get(
        ApiConfig.uri('/api/Communication/messages'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonMsgs = jsonDecode(response.body);
        final Map<String, List<dynamic>> mensagensAgrupadas = {};

        for (var m in jsonMsgs) {
          final sender = m['senderUserId']?.toString() ?? '';
          final receiver = m['receiverUserId']?.toString() ?? '';
          if (sender != _myUserId && receiver != _myUserId) continue;

          final otherUserId = sender == _myUserId ? receiver : sender;
          mensagensAgrupadas.putIfAbsent(otherUserId, () => []).add(m);
        }

        final List<_ConversationData> novasConversas = [];
        for (var entry in mensagensAgrupadas.entries) {
          final otherUserId = entry.key;
          final msgs = entry.value;

          final dadosAluno = await _buscarDadosAluno(otherUserId, token);
          msgs.sort((a, b) => (a['sentAt'] ?? '').compareTo(b['sentAt'] ?? ''));

          final parsedMessages = msgs.map((m) {
            String timeLabel = 'Agora';
            if (m['sentAt'] != null) {
              try {
                final dt = DateTime.parse(m['sentAt']).toLocal();
                timeLabel = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              } catch (_) {}
            }
            return _MessageData(
              isMine: m['senderUserId']?.toString() == _myUserId,
              text: m['messageContent'] ?? '',
              timeLabel: timeLabel,
            );
          }).toList();

          novasConversas.add(_ConversationData(
            id: otherUserId.hashCode,
            backendGuid: otherUserId,
            initials: dadosAluno['initials']!,
            name: dadosAluno['name']!,
            status: 'Online',
            timeLabel: parsedMessages.isNotEmpty ? parsedMessages.last.timeLabel : '',
            preview: parsedMessages.isNotEmpty ? parsedMessages.last.text : '',
            messages: parsedMessages,
          ));
        }

        if (widget.initialStudentId != null) {
          final initialIdInt = widget.initialStudentId.hashCode;
          if (!novasConversas.any((c) => c.id == initialIdInt)) {
            final studentName = widget.initialStudentName ?? 'Aluno';
            String initials = 'AL';
            if (studentName.isNotEmpty) {
              final parts = studentName.trim().split(' ');
              initials = parts.length > 1 
                  ? '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase() 
                  : studentName.substring(0, studentName.length >= 2 ? 2 : 1).toUpperCase();
            }
            novasConversas.insert(0, _ConversationData(
              id: initialIdInt, backendGuid: widget.initialStudentId!,
              initials: initials, name: studentName, status: 'Online',
              timeLabel: 'Agora', preview: 'Inicia a conversa...', messages: const [],
            ));
          }
        }

        setState(() {
          _conversations = novasConversas;
          if (widget.initialStudentId != null && _selectedConversationId == null) {
             _selectedConversationId = widget.initialStudentId.hashCode;
          } else if (_conversations.isNotEmpty && _selectedConversationId == null) {
             _selectedConversationId = _conversations.first.id;
          }
        });

        if (_hubConnection?.state != HubConnectionState.Connected && _myUserId != null) {
          await _iniciarSignalR(_myUserId!);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _composerController.dispose();
    _hubConnection?.stop();
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
      if (idx != -1) _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    setState(() {
      final idx = _conversations.indexWhere((c) => c.id == selected.id);
      if (idx != -1) {
        final updatedMessages = List<_MessageData>.from(_conversations[idx].messages)
          ..add(_MessageData(isMine: true, text: text, timeLabel: 'Agora'));
        _conversations[idx] = _conversations[idx].copyWith(messages: updatedMessages, preview: text, timeLabel: 'Agora');
      }
    });
    
    _composerController.clear();

    try {
      if (_hubConnection?.state == HubConnectionState.Connected && _myUserId != null) {
        await _hubConnection?.invoke(
          "SendPrivateMessage", 
          args: [_myUserId!, selected.backendGuid, text]
        );
      } else {
        final token = await TokenStorage().loadToken() ?? '';
        await http.post(
          ApiConfig.uri('/api/Communication/messages'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "senderUserId": _myUserId, 
            "receiverUserId": selected.backendGuid,
            "messageContent": text,
            "isRead": false,
            "sentAt": DateTime.now().toUtc().toIso8601String()
          }),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final selectedConversation = _selectedConversation;

    return Container(
      color: ChatsProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(54, 90, 23.148, 90),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 28.864),
                child: ProfessorMenuNav(selectedIndex: 4, notificationCount: 2, aulasEstaSemana: 8, ganhosPendentes: '150€', alunosAtivos: 12),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28.864, 28.864, 28.864, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 43.296, child: Text('Chats', style: TextStyle(color: ChatsProfessorColors.title, fontSize: ChatsProfessorFontSizes.title, fontWeight: FontWeight.w700))),
                      const SizedBox(height: 28.864),
                      SizedBox(
                        height: 797.368,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (_isLoading) return const Center(child: CircularProgressIndicator());
                            
                            const minWidth = 998.217;
                            final content = Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 313.492,
                                  child: _ChatListCard(controller: _searchController, onQueryChanged: (value) => setState(() => _query = value), conversations: _filteredConversations, selectedConversationId: selectedConversation?.id, onSelectConversation: _handleSelectConversation),
                                ),
                                const SizedBox(width: 28.868),
                                SizedBox(
                                  width: 655.857,
                                  child: _ConversationCard(conversation: selectedConversation, composerController: _composerController, onSend: _handleSendMessage),
                                ),
                              ],
                            );

                            if (constraints.maxWidth < minWidth) {
                              return SingleChildScrollView(scrollDirection: Axis.horizontal, child: ConstrainedBox(constraints: const BoxConstraints(minWidth: minWidth), child: content));
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
  const _ConversationData({required this.id, required this.backendGuid, required this.initials, required this.name, required this.status, required this.timeLabel, required this.preview, required this.messages, this.unreadCount});
  final int id;
  final String backendGuid;
  final String initials;
  final String name;
  final String status;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final List<_MessageData> messages;

  _ConversationData copyWith({String? timeLabel, String? preview, int? unreadCount, List<_MessageData>? messages}) {
    return _ConversationData(id: id, backendGuid: backendGuid, initials: initials, name: name, status: status, timeLabel: timeLabel ?? this.timeLabel, preview: preview ?? this.preview, unreadCount: unreadCount, messages: messages ?? this.messages);
  }
}

class _MessageData {
  const _MessageData({required this.isMine, required this.text, required this.timeLabel});
  final bool isMine;
  final String text;
  final String timeLabel;
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChatsProfessorColors.cardBackground, borderRadius: BorderRadius.circular(19.243),
        border: Border.all(color: ChatsProfessorColors.cardBorder, width: 1.203),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 4.811), blurRadius: 7.216, spreadRadius: -1.203), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 2.405), blurRadius: 4.811, spreadRadius: -2.405)],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _ChatListCard extends StatelessWidget {
  const _ChatListCard({required this.controller, required this.onQueryChanged, required this.conversations, required this.selectedConversationId, required this.onSelectConversation});
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
            height: 82.984, padding: const EdgeInsets.fromLTRB(19.243, 19.243, 19.243, 1.203),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203))),
            child: Container(
              height: 43.296, padding: const EdgeInsets.symmetric(horizontal: 14.432, vertical: 4.811),
              decoration: BoxDecoration(color: ChatsProfessorColors.searchBackground, borderRadius: BorderRadius.circular(12.027)),
              alignment: Alignment.centerLeft,
              child: TextField(controller: controller, onChanged: onQueryChanged, decoration: const InputDecoration(hintText: 'Procurar conversa...', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19.243),
              child: conversations.isEmpty 
                ? const Center(child: Text("Ainda não existem conversas", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final c = conversations[index];
                    return ChatListItem(initials: c.initials, name: c.name, timeLabel: c.timeLabel, preview: c.preview, unreadCount: c.unreadCount, selected: selectedConversationId == c.id, onTap: () => onSelectConversation(c.id));
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
  const _ConversationCard({required this.conversation, required this.composerController, required this.onSend});
  final _ConversationData? conversation;
  final TextEditingController composerController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(1.203),
      child: Column(
        children: [
          Container(
            height: 91.403, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203))),
            padding: const EdgeInsets.only(left: 19.243, bottom: 1.203),
            child: Row(
              children: [
                ChatAvatar(initials: conversation?.initials ?? '--', size: 48.107),
                const SizedBox(width: 14.432),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(conversation?.name ?? 'Sem conversa', style: const TextStyle(color: ChatsProfessorColors.title, fontSize: ChatsProfessorFontSizes.conversationName, fontWeight: FontWeight.w500)),
                      Text(conversation?.status ?? '', style: const TextStyle(color: ChatsProfessorColors.mutedText, fontSize: ChatsProfessorFontSizes.conversationStatus, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity, padding: const EdgeInsets.fromLTRB(19.243, 19.243, 19.243, 0),
              child: (conversation?.messages.isEmpty ?? true) 
                ? const Center(child: Text("Envie uma mensagem para iniciar", style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: conversation!.messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 19.243),
                  itemBuilder: (context, index) {
                    final m = conversation!.messages[index];
                    return ChatBubble(isMine: m.isMine, text: m.text, timeLabel: m.timeLabel, maxWidth: m.isMine ? 430.47 : 348.294);
                  },
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: ChatsProfessorColors.cardBorder, width: 1.203))),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20.445),
                child: Row(
                  children: [
                    _IconButton(icon: Icons.attach_file_rounded, onTap: () {}), const SizedBox(width: 9.621),
                    _IconButton(icon: Icons.image_rounded, onTap: () {}), const SizedBox(width: 9.621),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 43.296), padding: const EdgeInsets.symmetric(horizontal: 14.432),
                        decoration: BoxDecoration(color: ChatsProfessorColors.inputBackground, borderRadius: BorderRadius.circular(14.432)),
                        alignment: Alignment.centerLeft,
                        child: TextField(controller: composerController, textInputAction: TextInputAction.send, onSubmitted: (_) => onSend(), decoration: const InputDecoration(hintText: 'Escreva...', border: InputBorder.none, isDense: true)),
                      ),
                    ),
                    const SizedBox(width: 9.621),
                    InkWell(
                      onTap: onSend, borderRadius: BorderRadius.circular(14.432),
                      child: Ink(
                        height: 43.296, width: 48.107,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.432), gradient: const LinearGradient(colors: [ChatsProfessorColors.rightBubbleGradientStart, ChatsProfessorColors.rightBubbleGradientEnd])),
                        child: const Center(child: Icon(Icons.send_rounded, size: 19.243, color: Colors.white)),
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
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 43.296, height: 43.296,
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(12.027),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12.027), child: Center(child: Icon(icon, size: 24.053, color: ChatsProfessorColors.mutedText))),
      ),
    );
  }
}