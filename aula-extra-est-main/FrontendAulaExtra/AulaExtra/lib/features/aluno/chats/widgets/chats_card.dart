import 'dart:async';

import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/core/data/communication/contacts_service.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/features/aluno/chats/models/chat_bootstrap_args.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatsCard extends StatefulWidget {
  const ChatsCard({super.key, this.initialChat});

  final ChatBootstrapArgs? initialChat;

  @override
  State<ChatsCard> createState() => _ChatsCardState();
}

class _ChatsCardState extends State<ChatsCard> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _composerController = TextEditingController();

  final ScrollController _messagesScrollController = ScrollController();

  final ContactsService _contactsService = ContactsService();
  final UsersService _usersService = UsersService();
  final ChatFilesService _chatFilesService = ChatFilesService();
  final RealtimeChatService _realtimeChatService = RealtimeChatService();
  StreamSubscription<RealtimeChatEvent>? _chatSubscription;

  static const int _maxChatFileSizeBytes = 5 * 1024 * 1024;
  static const int _initialVisibleMessages = 20;
  static const int _historyPageSize = 20;

  String? _myUsername;
  String? _myDisplayName;
  String? _activeChannelName;

  String _query = '';
  int _selectedConversationId = 0;

  final Map<int, List<_MessageData>> _fullMessagesByConversationId =
      <int, List<_MessageData>>{};
  final Map<int, int> _visibleMessageCountByConversationId = <int, int>{};
  final Map<int, bool> _hasMoreHistoryByConversationId = <int, bool>{};
  bool _isLoadingMoreMessages = false;

  final Map<int, bool> _otherOnlineByConversationId = <int, bool>{};

  bool _isUpdatingInvite = false;
  bool _isBootstrappingInitialChat = false;
  bool _hasAppliedInitialChat = false;

  bool _isLoadingContacts = true;
  String? _contactsError;

  List<_ConversationData> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initRealtime());
    _messagesScrollController.addListener(_handleMessagesScroll);
  }

  void _handleMessagesScroll() {
    final selected = _selectedConversation;
    if (selected == null) return;

    if (_isLoadingMoreMessages) return;
    if (!_messagesScrollController.hasClients) return;

    // When user reaches the top, page in older messages.
    if (_messagesScrollController.position.pixels <=
        _messagesScrollController.position.minScrollExtent + 12) {
      _loadMoreMessages(selected.id);
    }
  }

  Future<void> _loadMoreMessages(int conversationId) async {
    final full =
        _fullMessagesByConversationId[conversationId] ?? const <_MessageData>[];
    final currentVisible =
        _visibleMessageCountByConversationId[conversationId] ??
        _initialVisibleMessages;

    if (full.length > currentVisible) {
      setState(() {
        final next = currentVisible + _historyPageSize;
        _visibleMessageCountByConversationId[conversationId] =
            _safeVisibleCount(next, full.length);
        _applyVisibleMessagesForConversation(conversationId);
      });
      return;
    }

    final selected = _selectedConversation;
    final activeChannelName = _activeChannelName;
    final oldestMessage = full.isNotEmpty ? full.first : null;
    final hasMoreHistory = _hasMoreHistoryByConversationId[conversationId] ?? false;
    if (!hasMoreHistory ||
        selected == null ||
        selected.id != conversationId ||
        activeChannelName == null ||
        activeChannelName.isEmpty ||
        oldestMessage == null) {
      return;
    }

    setState(() {
      _isLoadingMoreMessages = true;
    });

    try {
      await _realtimeChatService.loadOlderMessages(
        channelName: activeChannelName,
        before: oldestMessage.timestamp.subtract(
          const Duration(milliseconds: 1),
        ),
        limit: _historyPageSize,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMoreMessages = false;
        _contactsError = e.toString();
      });
    }
  }

  int _safeVisibleCount(int desired, int total) {
    if (total <= 0) return 0;
    if (total < _initialVisibleMessages) return total;
    return desired.clamp(_initialVisibleMessages, total);
  }

  String _contactPreview(ContactUserSummaryDto dto) {
    final lastMessage = dto.lastMessage?.trim();
    if (lastMessage != null && lastMessage.isNotEmpty) {
      return lastMessage;
    }

    if (dto.status.trim().toLowerCase() == 'accepted') {
      return 'Inicia a conversa...';
    }

    return 'Convite pendente';
  }

  String _contactTimeLabel(ContactUserSummaryDto dto) {
    final when = dto.lastMessageAt?.toLocal();
    if (when == null) {
      return '';
    }

    return _formatTime(when);
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

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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
        _contactsError =
            'Não foi possível identificar o utilizador para o chat.';
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
        _contactsError = e.toString();
      });
    }
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String _displayNameFor(ContactUserSummaryDto dto) {
    final dn = dto.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    final un = dto.username?.trim();
    if (un != null && un.isNotEmpty) return un;
    return 'Utilizador';
  }

  Future<void> _loadContacts() async {
    final previousSelectedUsername = _selectedConversation?.contactUsername
        .trim()
        .toLowerCase();

    setState(() {
      _isLoadingContacts = true;
      _contactsError = null;
    });

    try {
      final contacts = await _contactsService.getMyContacts();
      _applyContacts(
        contacts,
        previousSelectedUsername: previousSelectedUsername,
      );

      await _bootstrapInitialChatIfNeeded();
    } catch (e) {
      setState(() {
        _contactsError = e.toString();
        _conversations = [];
        _selectedConversationId = 0;
        _isLoadingContacts = false;
      });
    }
  }

  void _applyContacts(
    List<ContactUserSummaryDto> contacts, {
    String? previousSelectedUsername,
    String? preferredContactUserId,
    String? preferredContactUsername,
  }) {
    final conversations = <_ConversationData>[];
    final normalizedPreferredContactUserId = preferredContactUserId
        ?.trim()
        .toLowerCase();
    final preferredUsername = preferredContactUsername?.trim() ?? '';
    for (var i = 0; i < contacts.length; i++) {
      final dto = contacts[i];
      final name = _displayNameFor(dto);
      final normalizedContactUserId = dto.contactUserId.trim().toLowerCase();
      final username = (dto.username?.trim().isNotEmpty ?? false)
          ? dto.username!.trim()
          : (normalizedPreferredContactUserId != null &&
                  normalizedPreferredContactUserId.isNotEmpty &&
                  normalizedPreferredContactUserId == normalizedContactUserId)
              ? preferredUsername
              : '';
      conversations.add(
        _ConversationData(
          id: i + 1,
          contactUserId: dto.contactUserId,
          contactUsername: username,
          name: name,
          initials: _initialsFromName(name),
          status: dto.status,
          timeLabel: _contactTimeLabel(dto),
          preview: _contactPreview(dto),
          messages: const [],
        ),
      );
    }

    int selectedId = conversations.isNotEmpty ? conversations.first.id : 0;

    final normalizedPreferredContactUsername = preferredContactUsername
        ?.trim()
        .toLowerCase();
    if (normalizedPreferredContactUserId != null &&
        normalizedPreferredContactUserId.isNotEmpty) {
      final preferredIndex = conversations.indexWhere(
        (c) =>
            c.contactUserId.trim().toLowerCase() ==
            normalizedPreferredContactUserId,
      );
      if (preferredIndex != -1) {
        selectedId = conversations[preferredIndex].id;
      }
    } else if (normalizedPreferredContactUsername != null &&
        normalizedPreferredContactUsername.isNotEmpty) {
      final preferredIndex = conversations.indexWhere(
        (c) =>
            c.contactUsername.trim().toLowerCase() ==
            normalizedPreferredContactUsername,
      );
      if (preferredIndex != -1) {
        selectedId = conversations[preferredIndex].id;
      }
    } else if (previousSelectedUsername != null &&
        previousSelectedUsername.isNotEmpty) {
      final idx = conversations.indexWhere(
        (c) =>
            c.contactUsername.trim().toLowerCase() == previousSelectedUsername,
      );
      if (idx != -1) selectedId = conversations[idx].id;
    }

    setState(() {
      _conversations = conversations;
      _selectedConversationId = selectedId;
      _isLoadingContacts = false;
      _fullMessagesByConversationId.clear();
      _visibleMessageCountByConversationId.clear();
      _hasMoreHistoryByConversationId.clear();
      _otherOnlineByConversationId.clear();
      _activeChannelName = null;
    });
  }

  Future<void> _bootstrapInitialChatIfNeeded() async {
    final initialContactUserId = widget.initialChat?.contactUserId.trim();
    final initialContactUsername = widget.initialChat?.contactUsername?.trim();
    if (_hasAppliedInitialChat || _isBootstrappingInitialChat) return;
    if ((initialContactUserId == null || initialContactUserId.isEmpty) &&
        (initialContactUsername == null || initialContactUsername.isEmpty)) {
      _hasAppliedInitialChat = true;
      return;
    }

    _isBootstrappingInitialChat = true;

    try {
      var selected = _findConversationForInitialChat(
        contactUserId: initialContactUserId,
        contactUsername: initialContactUsername,
      );
      if (selected == null) {
        final updatedContacts = await _createInitialContact(
          contactUserId: initialContactUserId,
          contactUsername: initialContactUsername,
        );
        if (!mounted) return;
        _applyContacts(
          updatedContacts,
          preferredContactUserId: initialContactUserId,
          preferredContactUsername: initialContactUsername,
        );
        selected = _findConversationForInitialChat(
          contactUserId: initialContactUserId,
          contactUsername: initialContactUsername,
        );
      } else {
        setState(() {
          _selectedConversationId = selected!.id;
        });
      }

      if (selected != null &&
          selected.status.trim().toLowerCase() == 'accepted') {
        await _joinConversation(selected);
        await _sendBootstrapMessageIfNeeded(widget.initialChat?.initialMessage);
      }

      _hasAppliedInitialChat = true;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
      });
    } finally {
      _isBootstrappingInitialChat = false;
    }
  }

  Future<void> _sendBootstrapMessageIfNeeded(String? initialMessage) async {
    final text = initialMessage?.trim();
    final channelName = _activeChannelName;
    if (text == null || text.isEmpty) return;
    if (channelName == null || channelName.isEmpty) return;

    await _realtimeChatService.sendMessage(
      channelName: channelName,
      content: text,
    );
  }

  _ConversationData? _findConversationByContactUserId(String contactUserId) {
    final normalized = contactUserId.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final conversation in _conversations) {
      if (conversation.contactUserId.trim().toLowerCase() == normalized) {
        return conversation;
      }
    }

    return null;
  }

  _ConversationData? _findConversationByUsername(String username) {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final conversation in _conversations) {
      if (conversation.contactUsername.trim().toLowerCase() == normalized) {
        return conversation;
      }
    }

    return null;
  }

  _ConversationData? _findConversationForInitialChat({
    String? contactUserId,
    String? contactUsername,
  }) {
    if (contactUserId != null && contactUserId.trim().isNotEmpty) {
      final byUserId = _findConversationByContactUserId(contactUserId);
      if (byUserId != null) return byUserId;
    }

    if (contactUsername != null && contactUsername.trim().isNotEmpty) {
      return _findConversationByUsername(contactUsername);
    }

    return null;
  }

  Future<List<ContactUserSummaryDto>> _createInitialContact({
    String? contactUserId,
    String? contactUsername,
  }) async {
    final normalizedUserId = contactUserId?.trim();
    final normalizedUsername = contactUsername?.trim();

    if (normalizedUserId != null && normalizedUserId.isNotEmpty) {
      try {
        return await _contactsService.addContactByUserId(normalizedUserId);
      } catch (_) {
        if (normalizedUsername == null || normalizedUsername.isEmpty) {
          rethrow;
        }
      }
    }

    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      await _contactsService.addContactByUsername(normalizedUsername);
      return _contactsService.acceptInviteByUsername(normalizedUsername);
    }

    throw Exception('Não foi possível criar o contacto.');
  }

  Future<void> _showAddContactDialog() async {
    final controller = TextEditingController();
    final username = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar contacto'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Username'),
            autofocus: true,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    setState(() {
      _isLoadingContacts = true;
      _contactsError = null;
    });

    try {
      await _contactsService.addContactByUsername(trimmed);
      await _loadContacts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
        _isLoadingContacts = false;
      });
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

  Future<void> _joinConversation(_ConversationData conversation) async {
    if (conversation.status.trim().toLowerCase() != 'accepted') {
      _activeChannelName = null;
      return;
    }

    final myUsername = _myUsername;
    final myDisplayName = _myDisplayName;

    if (myUsername == null || myDisplayName == null) {
      await _initRealtime();
    }

    final username = _myUsername;
    final displayName = _myDisplayName;
    if (username == null || displayName == null) return;

    var otherUsername = conversation.contactUsername.trim();
    if (otherUsername.isEmpty) {
      final bootstrapArgs = widget.initialChat;
      final matchesBootstrapContact = bootstrapArgs != null &&
          bootstrapArgs.contactUserId.trim().isNotEmpty &&
          bootstrapArgs.contactUserId.trim().toLowerCase() ==
              conversation.contactUserId.trim().toLowerCase();
      if (matchesBootstrapContact) {
        otherUsername = bootstrapArgs.contactUsername?.trim() ?? '';
      }
    }

    if (otherUsername.isEmpty) {
      if (!mounted) return;
      setState(() {
        _contactsError = 'Este contacto não tem username.';
      });
      return;
    }

    try {
      await _realtimeChatService.connect(
        username: username,
        displayName: displayName,
      );
      _activeChannelName = await _realtimeChatService.joinDirectMessage(
        otherUsername: otherUsername,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    if (selected.status.trim().toLowerCase() != 'accepted') {
      setState(() {
        _contactsError = 'Convite ainda não aceite.';
      });
      return;
    }

    if (_activeChannelName == null || _activeChannelName!.isEmpty) {
      await _joinConversation(selected);
    }

    final active = _activeChannelName;
    if (active == null || active.isEmpty) return;

    try {
      await _realtimeChatService.sendMessage(
        channelName: active,
        content: text,
      );
      if (!mounted) return;
      _composerController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
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

      if (result == null || result.files.isEmpty) {
        return;
      }

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
        _contactsError = e.toString();
      });
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      setState(() {
        _contactsError = 'Link do ficheiro inválido.';
      });
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      setState(() {
        _contactsError = 'Não foi possível abrir o ficheiro.';
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
      if (selected.status.trim().toLowerCase() == 'accepted') {
        _joinConversation(selected);
      } else {
        _activeChannelName = null;
      }
    }
  }

  Future<void> _acceptInvite(_ConversationData conversation) async {
    final otherUsername = conversation.contactUsername.trim();
    if (otherUsername.isEmpty) return;

    setState(() {
      _isUpdatingInvite = true;
      _contactsError = null;
    });

    try {
      await _contactsService.acceptInviteByUsername(otherUsername);
      await _loadContacts();

      final selected = _selectedConversation;
      if (selected != null &&
          selected.status.trim().toLowerCase() == 'accepted') {
        await _joinConversation(selected);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingInvite = false;
        });
      }
    }
  }

  Future<void> _rejectInvite(_ConversationData conversation) async {
    final otherUsername = conversation.contactUsername.trim();
    if (otherUsername.isEmpty) return;

    setState(() {
      _isUpdatingInvite = true;
      _contactsError = null;
    });

    try {
      await _contactsService.rejectInviteByUsername(otherUsername);
      await _loadContacts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contactsError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingInvite = false;
        });
      }
    }
  }

  void _handleSendMessage() {
    _sendMessage();
  }

  void _onChatEvent(RealtimeChatEvent event) {
    if (!mounted) return;

    if (event is RealtimeChatRoomJoined) {
      _applyRoomHistory(
        event.channelName,
        event.messages,
        hasMoreHistory: event.hasMoreHistory,
      );
      _applyPresenceFromParticipants(event.channelName, event.participants);
      _markConversationRead(event.channelName);
      return;
    }

    if (event is RealtimeChatRoomHistoryLoaded) {
      _prependRoomHistory(
        event.channelName,
        event.messages,
        hasMoreHistory: event.hasMoreHistory,
      );
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
        _contactsError = event.message;
      });
    }
  }

  void _markConversationRead(String channelName) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel.trim().toLowerCase() !=
        channelName.trim().toLowerCase()) {
      return;
    }
    if (selected.status.trim().toLowerCase() != 'accepted') return;

    _realtimeChatService.markDirectMessagesRead(channelName: channelName);
  }

  void _applyMessagesRead(String channelName, List<String> messageIds) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final convoIdx = _conversations.indexWhere(
      (c) =>
          RealtimeChatConfig.dmChannelName(myUsername, c.contactUsername) ==
          channelName,
    );
    if (convoIdx == -1) return;

    final conversationId = _conversations[convoIdx].id;
    final full = List<_MessageData>.from(
      _fullMessagesByConversationId[conversationId] ??
          _conversations[convoIdx].messages,
    );
    if (full.isEmpty) return;

    final ids = messageIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return;

    var changed = false;
    for (var i = 0; i < full.length; i++) {
      final m = full[i];
      if (!m.isOutgoing) continue;
      if (m.isRead) continue;
      if (!ids.contains(m.id)) continue;

      full[i] = _MessageData(
        id: m.id,
        senderId: m.senderId,
        text: m.text,
        timestamp: m.timestamp,
        isOutgoing: m.isOutgoing,
        isRead: true,
        attachment: m.attachment,
      );
      changed = true;
    }

    if (!changed) return;

    setState(() {
      _fullMessagesByConversationId[conversationId] = full;
      if (_selectedConversationId == conversationId) {
        _applyVisibleMessagesForConversation(conversationId);
      } else {
        // Keep preview/time label in sync for non-selected convos as well.
        final visible = _conversations[convoIdx].messages;
        _conversations[convoIdx] = _conversations[convoIdx].copyWith(
          messages: visible,
        );
      }
    });
  }

  void _applyPresenceFromParticipants(
    String channelName,
    List<RealtimeChatParticipant> participants,
  ) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel != channelName) return;

    final otherUsername = selected.contactUsername.trim().toLowerCase();
    final isOnline = participants.any(
      (p) => p.isConnected && p.userId.trim().toLowerCase() == otherUsername,
    );

    setState(() {
      _otherOnlineByConversationId[selected.id] = isOnline;
    });
  }

  void _applyPresenceChange(String channelName, String userId, bool isOnline) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel != channelName) return;

    final otherUsername = selected.contactUsername.trim().toLowerCase();
    if (userId.trim().toLowerCase() != otherUsername) return;

    setState(() {
      _otherOnlineByConversationId[selected.id] = isOnline;
    });
  }

  void _applyRoomHistory(
    String channelName,
    List<RealtimeChatMessage> messages,
    {required bool hasMoreHistory,}
  ) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel != channelName) return;

    final mapped =
        messages
            .map(
              (m) => _MessageData(
                id: m.messageId,
                senderId: m.senderId,
                text: m.content,
                timestamp: m.timestamp.toLocal(),
                isOutgoing: m.senderId == myUsername,
                isRead: m.isRead,
                attachment: m.attachment,
              ),
            )
            .toList(growable: true)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      final idx = _conversations.indexWhere((c) => c.id == selected.id);
      if (idx == -1) return;

      final existing = List<_MessageData>.from(
        _fullMessagesByConversationId[selected.id] ?? const <_MessageData>[],
      );
      final mergedById = <String, _MessageData>{};
      for (final item in existing) {
        final key = item.id.trim();
        if (key.isNotEmpty) {
          mergedById[key] = item;
        }
      }
      for (final item in mapped) {
        final key = item.id.trim();
        if (key.isNotEmpty) {
          mergedById[key] = item;
        }
      }

      final merged = mergedById.values.toList(growable: true)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _fullMessagesByConversationId[selected.id] = merged;
      _hasMoreHistoryByConversationId[selected.id] = hasMoreHistory;
      _visibleMessageCountByConversationId[selected.id] = _safeVisibleCount(
        _visibleMessageCountByConversationId[selected.id] ??
            _initialVisibleMessages,
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
      _isLoadingMoreMessages = false;
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
      _visibleMessageCountByConversationId[conversationId] ??
          _initialVisibleMessages,
      full.length,
    );
    final start = (full.length - visibleCount).clamp(0, full.length);
    final visible = full.sublist(start);

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    _conversations[idx] = _conversations[idx].copyWith(messages: visible);
  }

  void _prependRoomHistory(
    String channelName,
    List<RealtimeChatMessage> messages, {
    required bool hasMoreHistory,
  }) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel != channelName) return;

    final mapped = messages
        .map(
          (m) => _MessageData(
            id: m.messageId,
            senderId: m.senderId,
            text: m.content,
            timestamp: m.timestamp.toLocal(),
            isOutgoing:
                m.senderId.trim().toLowerCase() ==
                myUsername.trim().toLowerCase(),
            isRead: m.isRead,
            attachment: m.attachment,
          ),
        )
        .toList(growable: true)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      final currentFull = List<_MessageData>.from(
        _fullMessagesByConversationId[selected.id] ?? const <_MessageData>[],
      );
      final mergedById = <String, _MessageData>{};
      for (final item in mapped) {
        final key = item.id.trim();
        if (key.isNotEmpty) {
          mergedById[key] = item;
        }
      }
      for (final item in currentFull) {
        final key = item.id.trim();
        if (key.isNotEmpty) {
          mergedById[key] = item;
        }
      }

      final merged = mergedById.values.toList(growable: true)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _fullMessagesByConversationId[selected.id] = merged;
      _hasMoreHistoryByConversationId[selected.id] = hasMoreHistory;
      final currentVisible =
          _visibleMessageCountByConversationId[selected.id] ??
          _initialVisibleMessages;
      _visibleMessageCountByConversationId[selected.id] = _safeVisibleCount(
        currentVisible + mapped.length,
        merged.length,
      );
      _applyVisibleMessagesForConversation(selected.id);
      _isLoadingMoreMessages = false;
    });
  }

  void _appendMessageToActive(String channelName, RealtimeChatMessage message) {
    final myUsername = _myUsername;
    if (myUsername == null) return;

    final selected = _selectedConversation;
    if (selected == null) return;

    final expectedChannel = RealtimeChatConfig.dmChannelName(
      myUsername,
      selected.contactUsername,
    );
    if (expectedChannel != channelName) return;

    final msg = _toMessageData(message, myUsername);

    setState(() {
      final idx = _conversations.indexWhere((c) => c.id == selected.id);
      if (idx == -1) return;

      final full = List<_MessageData>.from(
        _fullMessagesByConversationId[selected.id] ??
            _conversations[idx].messages,
      );
      full.add(msg);
      full.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _fullMessagesByConversationId[selected.id] = full;

      final currentVisible = _safeVisibleCount(
        _visibleMessageCountByConversationId[selected.id] ??
            _initialVisibleMessages,
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
        (c) =>
            RealtimeChatConfig.dmChannelName(myUsername, c.contactUsername) ==
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
        full.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _fullMessagesByConversationId[_conversations[idx].id] = full;

        final currentVisible = _safeVisibleCount(
          _visibleMessageCountByConversationId[_conversations[idx].id] ??
              _initialVisibleMessages,
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

  @override
  Widget build(BuildContext context) {
    final selected = _selectedConversation;
    final otherOnline = selected != null
        ? (_otherOnlineByConversationId[selected.id] ?? false)
        : false;
    final status = selected?.status.trim().toLowerCase();
    final canSend = status == 'accepted';

    return Container(
      padding: const EdgeInsets.all(ChatsConstants.borderWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ChatsConstants.cardRadius),
        border: Border.all(
          color: ChatsConstants.borderColorSoft,
          width: ChatsConstants.borderWidth,
        ),
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
                  onAddContact: _showAddContactDialog,
                  isLoading: _isLoadingContacts,
                  error: _contactsError,
                ),
              ),
              Expanded(
                child: _ChatPanel(
                  conversation: selected,
                  otherOnline: otherOnline,
                  messagesScrollController: _messagesScrollController,
                  isLoadingMore: _isLoadingMoreMessages,
                  composerController: _composerController,
                  canSend: canSend,
                  isUpdatingInvite: _isUpdatingInvite,
                  onAcceptInvite: selected == null
                      ? null
                      : () => _acceptInvite(selected),
                  onRejectInvite: selected == null
                      ? null
                      : () => _rejectInvite(selected),
                  onSend: _handleSendMessage,
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
    required this.onAddContact,
    required this.isLoading,
    required this.error,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final List<_ConversationData> conversations;
  final int? selectedConversationId;
  final ValueChanged<int> onSelectConversation;
  final VoidCallback onAddContact;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: ChatsConstants.borderColor,
            width: ChatsConstants.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: [
          _ConversationSearchHeader(
            controller: controller,
            onChanged: onQueryChanged,
            onAddContact: onAddContact,
            isLoading: isLoading,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(22.309, 8, 22.309, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ),
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
    required this.onAddContact,
    required this.isLoading,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddContact;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98.994,
      padding: const EdgeInsets.fromLTRB(22.309, 22.309, 22.309, 22.309),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ChatsConstants.borderColor,
            width: ChatsConstants.borderWidth,
          ),
        ),
      ),
      child: SizedBox(
        height: 52.983,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52.983,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(13.943),
                  border: Border.all(
                    color: ChatsConstants.borderColor,
                    width: ChatsConstants.borderWidth,
                  ),
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 22.309,
                      vertical: 11.154,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 52.983,
              height: 52.983,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(13.943),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13.943),
                  onTap: isLoading ? null : onAddContact,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.943),
                      border: Border.all(
                        color: ChatsConstants.borderColor,
                        width: ChatsConstants.borderWidth,
                      ),
                      color: const Color(0xFFF9FAFB),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      color: selected
          ? ChatsConstants.selectedConversationBackground
          : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 112.937,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ChatsConstants.borderColorSoft,
                width: ChatsConstants.borderWidth,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22.309,
            vertical: 22.309,
          ),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              child: Center(child: SizedBox.shrink()),
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
                decoration: const BoxDecoration(
                  color: ChatsConstants.dangerRed,
                  shape: BoxShape.circle,
                ),
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
    required this.otherOnline,
    required this.messagesScrollController,
    required this.isLoadingMore,
    required this.composerController,
    required this.canSend,
    required this.isUpdatingInvite,
    required this.onAcceptInvite,
    required this.onRejectInvite,
    required this.onSend,
    required this.onPickFile,
    required this.onOpenAttachment,
  });

  final _ConversationData? conversation;
  final bool otherOnline;
  final ScrollController messagesScrollController;
  final bool isLoadingMore;
  final TextEditingController composerController;
  final bool canSend;
  final bool isUpdatingInvite;
  final VoidCallback? onAcceptInvite;
  final VoidCallback? onRejectInvite;
  final VoidCallback onSend;
  final VoidCallback onPickFile;
  final ValueChanged<String> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final status = conversation?.status.trim().toLowerCase();
    final showInviteActions = status == 'pending';
    final showRequestedInfo = status == 'requested';

    final composerEnabled = conversation != null && canSend;
    final hintText = conversation == null
        ? 'Selecione uma conversa...'
        : composerEnabled
        ? 'Digite sua mensagem...'
        : showInviteActions
        ? 'Aceite o convite para começar...'
        : showRequestedInfo
        ? 'Pedido enviado. A aguardar aceitação...'
        : 'Chat indisponível.';

    return Column(
      children: [
        _ChatHeader(conversation: conversation, otherOnline: otherOnline),
        Expanded(
          child: _ChatMessages(
            controller: messagesScrollController,
            isLoadingMore: isLoadingMore,
            messages: conversation?.messages ?? const [],
            onOpenAttachment: onOpenAttachment,
          ),
        ),
        if (conversation != null && (showInviteActions || showRequestedInfo))
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: ChatsConstants.borderColor,
                  width: ChatsConstants.borderWidth,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22.309, 12, 22.309, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        showInviteActions
                            ? 'Convite pendente'
                            : 'A aguardar aceitação',
                        style: const TextStyle(
                          fontSize: 16.731,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6A7282),
                          height: 22.309 / 16.731,
                        ),
                      ),
                    ),
                    if (showInviteActions) ...[
                      TextButton(
                        onPressed: isUpdatingInvite ? null : onRejectInvite,
                        child: const Text('Rejeitar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isUpdatingInvite ? null : onAcceptInvite,
                        child: isUpdatingInvite
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Aceitar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        _ChatComposer(
          controller: composerController,
          enabled: composerEnabled,
          hintText: hintText,
          onSend: onSend,
          onPickFile: onPickFile,
        ),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conversation, required this.otherOnline});

  final _ConversationData? conversation;
  final bool otherOnline;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return Container(
      height: 101.783,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ChatsConstants.borderColor,
            width: ChatsConstants.borderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 22.309),
      child: Row(
        children: [
          SizedBox(
            width: 55.771,
            height: 55.771,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              child: Center(
                child: Text(
                  c?.initials ?? '--',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
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
                c == null ? '' : (otherOnline ? 'Online' : 'Offline'),
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
  const _ChatMessages({
    required this.controller,
    required this.isLoadingMore,
    required this.messages,
    required this.onOpenAttachment,
  });

  final ScrollController controller;
  final bool isLoadingMore;
  final List<_MessageData> messages;
  final ValueChanged<String> onOpenAttachment;

  String _formatDay(DateTime dt) {
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (isLoadingMore) {
      items.add(
        const Padding(
          padding: EdgeInsets.only(bottom: 16.731),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    DateTime? lastDay;
    for (final m in messages) {
      final day = DateTime(
        m.timestamp.year,
        m.timestamp.month,
        m.timestamp.day,
      );
      if (lastDay == null || day != lastDay) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.365),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    _formatDay(m.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        lastDay = day;
      }

      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.731),
          child: _ChatMessage(
            text: m.text,
            time: _formatTime(m.timestamp),
            isOutgoing: m.isOutgoing,
            isRead: m.isRead,
            attachment: m.attachment,
            onOpenAttachment: m.attachment == null
                ? null
                : () => onOpenAttachment(m.attachment!.downloadUrl),
          ),
        ),
      );
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(22.309),
      children: items,
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({
    required this.text,
    required this.time,
    required this.isRead,
    this.isOutgoing = false,
    this.attachment,
    this.onOpenAttachment,
  });

  final String text;
  final String time;
  final bool isOutgoing;
  final bool isRead;
  final RealtimeChatAttachment? attachment;
  final VoidCallback? onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final messageTextColor = isOutgoing
        ? Colors.white
        : const Color(0xFF101828);
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

    final hasVisibleText =
        text.trim().isNotEmpty &&
        (attachment == null ||
            text.trim() != '[Ficheiro: ${attachment!.fileName}]');

    return Column(
      crossAxisAlignment: isOutgoing
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 349.399),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22.309, 11.154, 22.309, 11.154),
            decoration: bubbleDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attachment != null)
                  _ChatAttachmentCard(
                    attachment: attachment!,
                    isOutgoing: isOutgoing,
                    onTap: onOpenAttachment,
                  ),
                if (attachment != null && hasVisibleText)
                  const SizedBox(height: 10),
                if (hasVisibleText)
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 19.52,
                      fontWeight: FontWeight.w400,
                      color: messageTextColor,
                      height: 27.886 / 19.52,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5.577),
        Padding(
          padding: EdgeInsets.only(
            left: isOutgoing ? 0 : 11.154,
            right: isOutgoing ? 11.154 : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16.731,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A7282),
                  height: 22.309 / 16.731,
                ),
              ),
              if (isOutgoing) ...[
                const SizedBox(width: 8),
                Text(
                  isRead ? 'Lida' : 'Não lida',
                  style: const TextStyle(
                    fontSize: 16.731,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                    height: 22.309 / 16.731,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.onSend,
    required this.onPickFile,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ChatsConstants.borderColor,
            width: ChatsConstants.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22.309, 23.703, 22.309, 22.309),
          child: Row(
            children: [
              _IconSquareButton(
                icon: Icons.attach_file_rounded,
                onTap: enabled ? onPickFile : () {},
              ),
              const SizedBox(width: 16.731),
              _IconSquareButton(icon: Icons.image_outlined, onTap: () {}),
              const SizedBox(width: 16.731),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58.56),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(13.943),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.394,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    textInputAction: TextInputAction.send,
                    onSubmitted: enabled ? (_) => onSend() : null,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontSize: 22.309,
                        fontWeight: FontWeight.w400,
                        color: Color(0x800A0A0A),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 22.309,
                        vertical: 11.154,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.731),
              _SendSquareButton(onTap: enabled ? onSend : null),
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

class _ConversationData {
  const _ConversationData({
    required this.id,
    required this.contactUserId,
    required this.contactUsername,
    required this.name,
    required this.initials,
    required this.status,
    required this.timeLabel,
    required this.preview,
    required this.messages,
    this.unreadCount,
  });

  final int id;
  final String contactUserId;
  final String contactUsername;
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
      contactUserId: contactUserId,
      contactUsername: contactUsername,
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

class _ChatAttachmentCard extends StatelessWidget {
  const _ChatAttachmentCard({
    required this.attachment,
    required this.isOutgoing,
    this.onTap,
  });

  final RealtimeChatAttachment attachment;
  final bool isOutgoing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isOutgoing ? Colors.white : const Color(0xFF101828);
    final secondary = isOutgoing
        ? Colors.white.withValues(alpha: 0.8)
        : const Color(0xFF6A7282);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutgoing
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutgoing
                ? Colors.white.withValues(alpha: 0.22)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file_rounded, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(attachment.fileSize),
                    style: TextStyle(color: secondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.download_rounded, color: foreground),
          ],
        ),
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  final decimals = size >= 10 || unitIndex == 0 ? 0 : 1;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}
