import 'dart:async';

import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/contacts_service.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_bubble.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_list_item.dart';
import 'package:aula_extra/features/professor/chats/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatsProfessorContentSection extends StatefulWidget {
  const ChatsProfessorContentSection({
    super.key,
    this.initialStudentUsername,
    this.initialStudentName,
  });

  final String? initialStudentUsername;
  final String? initialStudentName;

  @override
  State<ChatsProfessorContentSection> createState() =>
      _ChatsProfessorContentSectionState();
}

class _ChatsProfessorContentSectionState
    extends State<ChatsProfessorContentSection> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();

  final ProfessorsService _professorsService = ProfessorsService();
  final ContactsService _contactsService = ContactsService();
  final UsersService _usersService = UsersService();
  final ChatFilesService _chatFilesService = ChatFilesService();
  final RealtimeChatService _realtimeChatService = RealtimeChatService();

  static const int _maxChatFileSizeBytes = 5 * 1024 * 1024;

  StreamSubscription<RealtimeChatEvent>? _chatSubscription;

  String _query = '';
  int _selectedConversationId = 0;
  bool _isLoading = true;
  String? _errorMessage;

  String? _myUsername;
  String? _myDisplayName;
  String? _activeChannelName;

  final Map<int, List<_MessageData>> _fullMessagesByConversationId =
      <int, List<_MessageData>>{};
  final Map<int, int> _visibleMessageCountByConversationId = <int, int>{};
  final Map<int, bool> _otherOnlineByConversationId = <int, bool>{};
  bool _isLoadingMoreMessages = false;

  List<_ConversationData> _conversations = <_ConversationData>[];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initRealtime());
    _messagesScrollController.addListener(_handleMessagesScroll);
  }

  void _handleMessagesScroll() {
    final selected = _selectedConversation;
    if (selected == null) return;
    if (_isLoadingMoreMessages) return;
    if (!_messagesScrollController.hasClients) return;

    if (_messagesScrollController.position.pixels <=
        _messagesScrollController.position.minScrollExtent + 12) {
      _loadMoreMessages(selected.id);
    }
  }

  Future<void> _loadMoreMessages(int conversationId) async {
    final full =
        _fullMessagesByConversationId[conversationId] ?? const <_MessageData>[];
    final currentVisible =
        _visibleMessageCountByConversationId[conversationId] ?? 20;
    if (full.length <= currentVisible) return;

    setState(() {
      _isLoadingMoreMessages = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      final next = currentVisible + 20;
      _visibleMessageCountByConversationId[conversationId] = _safeVisibleCount(
        next,
        full.length,
      );
      _applyVisibleMessagesForConversation(conversationId);
      _isLoadingMoreMessages = false;
    });
  }

  int _safeVisibleCount(int desired, int total) {
    if (total <= 0) return 0;
    if (total < 20) return total;
    return desired.clamp(20, total);
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_messagesScrollController.hasClients) return;

    final target = _messagesScrollController.position.maxScrollExtent;
    if (!animated) {
      _messagesScrollController.jumpTo(target);
      return;
    }

    _messagesScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadStudents() async {
    final previousUsername = _selectedConversation?.username
        .trim()
        .toLowerCase();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final students = await _professorsService.fetchMeusAlunos();
      final conversations = <_ConversationData>[];

      for (var index = 0; index < students.length; index++) {
        final student = students[index];
        final username = student.username.trim();
        if (username.isEmpty) continue;

        conversations.add(
          _ConversationData(
            id: index + 1,
            username: username,
            initials: _initialsFromName(student.fullName),
            name: student.fullName,
            status: 'Offline',
            timeLabel: '',
            preview: 'Inicia a conversa...',
            messages: const <_MessageData>[],
          ),
        );
      }

      final initialUsername = widget.initialStudentUsername?.trim();
      final initialName = widget.initialStudentName?.trim();
      if (initialUsername != null && initialUsername.isNotEmpty) {
        final exists = conversations.any(
          (conversation) =>
              conversation.username.trim().toLowerCase() ==
              initialUsername.toLowerCase(),
        );
        if (!exists) {
          final fallbackName = (initialName != null && initialName.isNotEmpty)
              ? initialName
              : initialUsername;
          conversations.insert(
            0,
            _ConversationData(
              id: 1,
              username: initialUsername,
              initials: _initialsFromName(fallbackName),
              name: fallbackName,
              status: 'Offline',
              timeLabel: '',
              preview: 'Inicia a conversa...',
              messages: const <_MessageData>[],
            ),
          );
          for (var i = 1; i < conversations.length; i++) {
            conversations[i] = conversations[i].copyWith(id: i + 1);
          }
        }
      }

      var selectedId = conversations.isNotEmpty ? conversations.first.id : 0;
      if (previousUsername != null && previousUsername.isNotEmpty) {
        final previousMatch = conversations.indexWhere(
          (conversation) =>
              conversation.username.trim().toLowerCase() == previousUsername,
        );
        if (previousMatch != -1) selectedId = conversations[previousMatch].id;
      }

      if (initialUsername != null && initialUsername.isNotEmpty) {
        final initialMatch = conversations.indexWhere(
          (conversation) =>
              conversation.username.trim().toLowerCase() ==
              initialUsername.toLowerCase(),
        );
        if (initialMatch != -1) selectedId = conversations[initialMatch].id;
      }

      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _selectedConversationId = selectedId;
        _fullMessagesByConversationId.clear();
        _visibleMessageCountByConversationId.clear();
        _otherOnlineByConversationId.clear();
        _activeChannelName = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _conversations = <_ConversationData>[];
        _selectedConversationId = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _initRealtime() async {
    String? username;
    String? displayName;

    try {
      final user = context.read<UserProvider>();
      username = user.account?.username?.trim();
      displayName = user.account?.fullName?.trim();
    } catch (_) {}

    if (username == null || username.isEmpty) {
      try {
        final me = await _usersService.getMe();
        username = me.username?.trim();
        displayName = me.displayName?.trim();
      } catch (_) {}
    }

    if (!mounted) return;
    if (username == null || username.isEmpty) {
      setState(() {
        _errorMessage = 'Não foi possível identificar o professor para o chat.';
      });
      return;
    }

    displayName = (displayName == null || displayName.isEmpty)
        ? username
        : displayName;

    setState(() {
      _myUsername = username;
      _myDisplayName = displayName;
    });

    try {
      await _realtimeChatService.connect(
        username: username,
        displayName: displayName,
      );
      await _chatSubscription?.cancel();
      _chatSubscription = _realtimeChatService.events.listen(_onChatEvent);

      final selected = _selectedConversation;
      if (selected != null) {
        await _joinConversation(selected);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _joinConversation(_ConversationData conversation) async {
    final username = conversation.username.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Este aluno não tem username disponível.';
      });
      return;
    }

    final myUsername = _myUsername;
    final myDisplayName = _myDisplayName;
    if (myUsername == null || myDisplayName == null) {
      await _initRealtime();
    }

    if (_myUsername == null || _myDisplayName == null) return;

    final expectedChannelName = RealtimeChatConfig.dmChannelName(
      _myUsername!,
      username,
    );
    if (_activeChannelName?.trim().toLowerCase() ==
            expectedChannelName.trim().toLowerCase() &&
        _realtimeChatService.isConnected) {
      return;
    }

    try {
      await _contactsService.acceptInviteByUsername(username);
    } catch (_) {}

    try {
      await _realtimeChatService.connect(
        username: _myUsername!,
        displayName: _myDisplayName!,
      );
      final channelName = await _realtimeChatService.joinDirectMessage(
        otherUsername: username,
      );
      _activeChannelName = channelName;
      _markConversationRead(channelName);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    if (_activeChannelName == null || _activeChannelName!.isEmpty) {
      await _joinConversation(selected);
    }

    final channelName = _activeChannelName;
    if (channelName == null || channelName.isEmpty) return;

    try {
      await _realtimeChatService.sendMessage(
        channelName: channelName,
        content: text,
      );
      if (!mounted) return;
      _composerController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _pickAndSendFile() async {
    final selected = _selectedConversation;
    if (selected == null) return;

    if (_activeChannelName == null || _activeChannelName!.isEmpty) {
      await _joinConversation(selected);
    }

    final channelName = _activeChannelName;
    final username = _myUsername;
    if (channelName == null ||
        channelName.isEmpty ||
        username == null ||
        username.isEmpty) {
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;
      final bytes = pickedFile.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Não foi possível ler o ficheiro selecionado.');
      }

      if (bytes.length > _maxChatFileSizeBytes) {
        throw Exception('O ficheiro excede o limite de 5 MB.');
      }

      final uploaded = await _chatFilesService.uploadFile(
        bytes: bytes,
        fileName: pickedFile.name,
        contentType: _guessContentType(pickedFile.name),
        userId: username,
        roomId: channelName,
      );

      final caption = _composerController.text.trim();
      await _realtimeChatService.sendFileMessage(
        channelName: channelName,
        fileId: uploaded.fileId,
        caption: caption.isEmpty ? null : caption,
      );

      if (!mounted) return;
      _composerController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Link do ficheiro inválido.';
      });
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      setState(() {
        _errorMessage = 'Não foi possível abrir o ficheiro.';
      });
    }
  }

  _MessageData _toMessageData(RealtimeChatMessage message, String myUsername) {
    return _MessageData(
      id: message.messageId,
      senderId: message.senderId,
      text: message.content,
      timestamp: message.timestamp.toLocal(),
      isOutgoing:
          message.senderId.trim().toLowerCase() ==
          myUsername.trim().toLowerCase(),
      isRead: message.isRead,
      attachment: message.attachment,
    );
  }

  String _guessContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _composerController.dispose();
    _messagesScrollController.removeListener(_handleMessagesScroll);
    _messagesScrollController.dispose();
    _chatSubscription?.cancel();
    _realtimeChatService.disconnect();
    _realtimeChatService.dispose();
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
    return _conversations
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  void _handleSelectConversation(int id) {
    setState(() {
      _selectedConversationId = id;
      final idx = _conversations.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      }
    });

    final selected = _selectedConversation;
    if (selected != null) {
      _joinConversation(selected);
    }
  }

  void _onChatEvent(RealtimeChatEvent event) {
    if (!mounted) return;

    if (event is RealtimeChatRoomJoined) {
      _applyRoomHistory(event.channelName, event.messages);
      _applyPresenceFromParticipants(event.channelName, event.participants);
      _markConversationRead(event.channelName);
      return;
    }

    if (event is RealtimeChatMessageReceived) {
      if (event.message.isSystemFileNotification) return;
      _appendMessageToActive(event.channelName, event.message);
      final myUsername = _myUsername;
      if (myUsername != null &&
          event.message.senderId.trim().toLowerCase() !=
              myUsername.trim().toLowerCase()) {
        _markConversationRead(event.channelName);
      }
      return;
    }

    if (event is RealtimeChatDirectMessageReceived) {
      if (event.message.isSystemFileNotification) return;
      _applyDirectMessageNotification(event.channelName, event.message);
      final myUsername = _myUsername;
      if (myUsername != null &&
          event.message.senderId.trim().toLowerCase() !=
              myUsername.trim().toLowerCase()) {
        _markConversationRead(event.channelName);
      }
      return;
    }

    if (event is RealtimeChatMessagesRead) {
      _applyMessagesRead(event.channelName, event.messageIds);
      return;
    }

    if (event is RealtimeChatUserPresenceChanged) {
      _applyPresenceChange(event.channelName, event.userId, event.isOnline);
      return;
    }

    if (event is RealtimeChatError) {
      setState(() {
        _errorMessage = event.message;
      });
    }
  }

  void _applyRoomHistory(
    String channelName,
    List<RealtimeChatMessage> messages,
  ) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.username,
    );
    if (expectedChannel != channelName) return;

    final mapped =
        messages
            .map(
              (message) => _MessageData(
                id: message.messageId,
                senderId: message.senderId,
                text: message.content,
                timestamp: message.timestamp.toLocal(),
                isOutgoing:
                    message.senderId.trim().toLowerCase() ==
                    myUsername.trim().toLowerCase(),
                isRead: message.isRead,
                attachment: message.attachment,
              ),
            )
            .toList(growable: true)
          ..sort((left, right) => left.timestamp.compareTo(right.timestamp));

    setState(() {
      final idx = _conversations.indexWhere(
        (conversation) => conversation.id == selected.id,
      );
      if (idx == -1) return;

      final existing = List<_MessageData>.from(
        _fullMessagesByConversationId[selected.id] ?? const <_MessageData>[],
      );
      final mergedById = <String, _MessageData>{};

      for (final item in existing) {
        final key = item.id.trim();
        if (key.isEmpty) continue;
        mergedById[key] = item;
      }

      for (final item in mapped) {
        final key = item.id.trim();
        if (key.isEmpty) continue;
        mergedById[key] = item;
      }

      final merged = mergedById.values.toList(growable: true)
        ..sort((left, right) => left.timestamp.compareTo(right.timestamp));

      _fullMessagesByConversationId[selected.id] = merged;
      _visibleMessageCountByConversationId[selected.id] = _safeVisibleCount(
        _visibleMessageCountByConversationId[selected.id] ?? 20,
        merged.length,
      );
      _applyVisibleMessagesForConversation(selected.id);

      final visible = _conversations[idx].messages;
      final last = visible.isNotEmpty ? visible.last : null;
      _conversations[idx] = _conversations[idx].copyWith(
        messages: visible,
        preview: last?.text ?? '',
        timeLabel: last != null ? _formatTime(last.timestamp) : '',
      );
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: false),
    );
  }

  void _applyVisibleMessagesForConversation(int conversationId) {
    final selected = _selectedConversation;
    if (selected == null || selected.id != conversationId) return;

    final full =
        _fullMessagesByConversationId[conversationId] ?? const <_MessageData>[];
    final visibleCount = _safeVisibleCount(
      _visibleMessageCountByConversationId[conversationId] ?? 20,
      full.length,
    );
    final start = (full.length - visibleCount).clamp(0, full.length);
    final visible = full.sublist(start);

    final idx = _conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (idx == -1) return;
    _conversations[idx] = _conversations[idx].copyWith(messages: visible);
  }

  void _appendMessageToActive(String channelName, RealtimeChatMessage message) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.username,
    );
    if (expectedChannel != channelName) return;

    final msg = _toMessageData(message, myUsername);

    setState(() {
      final idx = _conversations.indexWhere(
        (conversation) => conversation.id == selected.id,
      );
      if (idx == -1) return;

      final full = List<_MessageData>.from(
        _fullMessagesByConversationId[selected.id] ??
            _conversations[idx].messages,
      );
      full.add(msg);
      full.sort((left, right) => left.timestamp.compareTo(right.timestamp));
      _fullMessagesByConversationId[selected.id] = full;

      final currentVisible = _safeVisibleCount(
        _visibleMessageCountByConversationId[selected.id] ?? 20,
        full.length,
      );
      _visibleMessageCountByConversationId[selected.id] = currentVisible;
      final visible = full.sublist(
        (full.length - currentVisible).clamp(0, full.length),
      );

      _conversations[idx] = _conversations[idx].copyWith(
        messages: visible,
        preview: msg.previewText,
        timeLabel: _formatTime(msg.timestamp),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _applyDirectMessageNotification(
    String channelName,
    RealtimeChatMessage message,
  ) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final msg = _toMessageData(message, myUsername);

    setState(() {
      final idx = _conversations.indexWhere(
        (conversation) =>
            RealtimeChatConfig.dmChannelName(
              myUsername,
              conversation.username,
            ) ==
            channelName,
      );
      if (idx == -1) return;

      final isSelected = _conversations[idx].id == _selectedConversationId;
      final unread = isSelected
          ? 0
          : ((_conversations[idx].unreadCount ?? 0) + 1);

      _conversations[idx] = _conversations[idx].copyWith(
        preview: msg.previewText,
        timeLabel: _formatTime(msg.timestamp),
        unreadCount: unread,
      );

      if (isSelected) {
        final full = List<_MessageData>.from(
          _fullMessagesByConversationId[_conversations[idx].id] ??
              _conversations[idx].messages,
        );
        full.add(msg);
        full.sort((left, right) => left.timestamp.compareTo(right.timestamp));
        _fullMessagesByConversationId[_conversations[idx].id] = full;

        final currentVisible = _safeVisibleCount(
          _visibleMessageCountByConversationId[_conversations[idx].id] ?? 20,
          full.length,
        );
        final visible = full.sublist(
          (full.length - currentVisible).clamp(0, full.length),
        );
        _conversations[idx] = _conversations[idx].copyWith(messages: visible);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _applyMessagesRead(String channelName, List<String> messageIds) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final conversationIndex = _conversations.indexWhere(
      (conversation) =>
          RealtimeChatConfig.dmChannelName(myUsername, conversation.username) ==
          channelName,
    );
    if (conversationIndex == -1) return;

    final conversationId = _conversations[conversationIndex].id;
    final full = List<_MessageData>.from(
      _fullMessagesByConversationId[conversationId] ??
          _conversations[conversationIndex].messages,
    );
    if (full.isEmpty) return;

    final ids = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return;

    var changed = false;
    for (var i = 0; i < full.length; i++) {
      final message = full[i];
      if (!message.isOutgoing || message.isRead || !ids.contains(message.id))
        continue;

      full[i] = _MessageData(
        id: message.id,
        senderId: message.senderId,
        text: message.text,
        timestamp: message.timestamp,
        isOutgoing: true,
        isRead: true,
        attachment: message.attachment,
      );
      changed = true;
    }

    if (!changed) return;

    setState(() {
      _fullMessagesByConversationId[conversationId] = full;
      if (_selectedConversationId == conversationId) {
        _applyVisibleMessagesForConversation(conversationId);
      } else {
        final visible = _conversations[conversationIndex].messages;
        _conversations[conversationIndex] = _conversations[conversationIndex]
            .copyWith(messages: visible);
      }
    });
  }

  void _applyPresenceFromParticipants(
    String channelName,
    List<RealtimeChatParticipant> participants,
  ) {
    final conversationIndex = _conversationIndexByChannel(channelName);
    if (conversationIndex == -1) return;

    final conversation = _conversations[conversationIndex];
    final targetUsername = conversation.username.trim().toLowerCase();
    final isOnline = participants.any(
      (participant) =>
          participant.isConnected &&
          participant.userId.trim().toLowerCase() == targetUsername,
    );

    _setConversationPresence(conversationIndex, isOnline);
  }

  void _applyPresenceChange(String channelName, String userId, bool isOnline) {
    final conversationIndex = _conversationIndexByChannel(channelName);
    if (conversationIndex == -1) return;

    final conversation = _conversations[conversationIndex];
    if (conversation.username.trim().toLowerCase() !=
        userId.trim().toLowerCase())
      return;

    _setConversationPresence(conversationIndex, isOnline);
  }

  void _setConversationPresence(int conversationIndex, bool isOnline) {
    final conversation = _conversations[conversationIndex];
    setState(() {
      _otherOnlineByConversationId[conversation.id] = isOnline;
      _conversations[conversationIndex] = conversation.copyWith(
        status: isOnline ? 'Online' : 'Offline',
      );
    });
  }

  void _markConversationRead(String channelName) {
    final selected = _selectedConversation;
    final myUsername = _myUsername;
    if (selected == null || myUsername == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.username,
    );
    if (expectedChannel.trim().toLowerCase() !=
        channelName.trim().toLowerCase())
      return;

    _realtimeChatService.markDirectMessagesRead(channelName: channelName);
  }

  int _conversationIndexByChannel(String channelName) {
    final myUsername = _myUsername;
    if (myUsername == null || channelName.trim().isEmpty) return -1;

    return _conversations.indexWhere(
      (conversation) =>
          RealtimeChatConfig.dmChannelName(
            myUsername,
            conversation.username,
          ).trim().toLowerCase() ==
          channelName.trim().toLowerCase(),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '--';
    if (parts.length == 1) {
      final single = parts.first;
      return single.substring(0, single.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
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
                            if (_isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (_errorMessage != null &&
                                _conversations.isEmpty) {
                              return Center(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: ChatsProfessorColors.mutedText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

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
                                    onQueryChanged: (value) =>
                                        setState(() => _query = value),
                                    conversations: _filteredConversations,
                                    selectedConversationId:
                                        selectedConversation?.id,
                                    onSelectConversation:
                                        _handleSelectConversation,
                                  ),
                                ),
                                const SizedBox(width: gap),
                                SizedBox(
                                  width: rightWidth,
                                  child: _ConversationCard(
                                    conversation: selectedConversation,
                                    messagesScrollController:
                                        _messagesScrollController,
                                    isLoadingMore: _isLoadingMoreMessages,
                                    composerController: _composerController,
                                    onSend: _sendMessage,
                                    onPickFile: _pickAndSendFile,
                                    onOpenAttachment: _openExternalUrl,
                                  ),
                                ),
                              ],
                            );

                            if (constraints.maxWidth < minWidth) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: minWidth,
                                  ),
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
    required this.username,
    required this.initials,
    required this.name,
    required this.status,
    required this.timeLabel,
    required this.preview,
    required this.messages,
    this.unreadCount,
  });

  final int id;
  final String username;
  final String initials;
  final String name;
  final String status;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final List<_MessageData> messages;

  _ConversationData copyWith({
    int? id,
    String? timeLabel,
    String? preview,
    int? unreadCount,
    List<_MessageData>? messages,
    String? status,
  }) {
    return _ConversationData(
      id: id ?? this.id,
      username: username,
      initials: initials,
      name: name,
      status: status ?? this.status,
      timeLabel: timeLabel ?? this.timeLabel,
      preview: preview ?? this.preview,
      unreadCount: unreadCount,
      messages: messages ?? this.messages,
    );
  }
}

class _MessageData {
  const _MessageData({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    required this.isRead,
    this.attachment,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final bool isRead;
  final RealtimeChatAttachment? attachment;

  String get previewText =>
      attachment != null ? '📎 ${attachment!.fileName}' : text;
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChatsProfessorColors.cardBackground,
        borderRadius: BorderRadius.circular(19.243),
        border: Border.all(
          color: ChatsProfessorColors.cardBorder,
          width: 1.203,
        ),
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
                bottom: BorderSide(
                  color: ChatsProfessorColors.cardBorder,
                  width: 1.203,
                ),
              ),
            ),
            child: Container(
              height: 43.296,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.432,
                vertical: 4.811,
              ),
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
    required this.messagesScrollController,
    required this.isLoadingMore,
    required this.composerController,
    required this.onSend,
    required this.onPickFile,
    required this.onOpenAttachment,
  });

  final _ConversationData? conversation;
  final ScrollController messagesScrollController;
  final bool isLoadingMore;
  final TextEditingController composerController;
  final VoidCallback onSend;
  final VoidCallback onPickFile;
  final ValueChanged<String> onOpenAttachment;

  String _formatTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

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
                bottom: BorderSide(
                  color: ChatsProfessorColors.cardBorder,
                  width: 1.203,
                ),
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
                        height:
                            32.472 / ChatsProfessorFontSizes.conversationName,
                      ),
                    ),
                    Text(
                      c?.status ?? '',
                      style: const TextStyle(
                        color: ChatsProfessorColors.mutedText,
                        fontSize: ChatsProfessorFontSizes.conversationStatus,
                        fontWeight: FontWeight.w400,
                        height:
                            19.243 / ChatsProfessorFontSizes.conversationStatus,
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
              child: ListView.builder(
                controller: messagesScrollController,
                padding: EdgeInsets.zero,
                itemCount: (c?.messages.length ?? 0) + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoadingMore && index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 19.243),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final offset = isLoadingMore ? 1 : 0;
                  final m = c!.messages[index - offset];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == (c.messages.length + offset - 1)
                          ? 0
                          : 19.243,
                    ),
                    child: ChatBubble(
                      isMine: m.isOutgoing,
                      text: m.text,
                      timeLabel: _formatTime(m.timestamp),
                      maxWidth: m.isOutgoing ? 430.47 : 348.294,
                      attachment: m.attachment,
                      onAttachmentTap: m.attachment == null
                          ? null
                          : () => onOpenAttachment(m.attachment!.downloadUrl),
                    ),
                  );
                },
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ChatsProfessorColors.cardBorder,
                  width: 1.203,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 19.243,
                  right: 19.243,
                  top: 20.445,
                  bottom: 20.445,
                ),
                child: Row(
                  children: [
                    _IconButton(
                      icon: Icons.attach_file_rounded,
                      onTap: onPickFile,
                    ),
                    const SizedBox(width: 9.621),
                    _IconButton(icon: Icons.image_rounded, onTap: () {}),
                    const SizedBox(width: 9.621),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 43.296),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.432,
                          vertical: 4.811,
                        ),
                        decoration: BoxDecoration(
                          color: ChatsProfessorColors.inputBackground,
                          borderRadius: BorderRadius.circular(14.432),
                          border: Border.all(
                            color: Colors.transparent,
                            width: 1.203,
                          ),
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
                    _ProfessorSendSquareButton(onTap: onSend),
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
      width: 43.296,
      height: 43.296,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.027),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.027),
          child: Center(
            child: Icon(
              icon,
              size: 24.053,
              color: ChatsProfessorColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfessorSendSquareButton extends StatelessWidget {
  const _ProfessorSendSquareButton({required this.onTap});

  final VoidCallback? onTap;

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
              child: Icon(
                Icons.near_me_outlined,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
