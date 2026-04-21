import 'dart:async';

import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_composer.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_conversation_header.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_message_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMobileConversationSection extends StatefulWidget {
  const ChatMobileConversationSection({super.key, required this.contact});

  final ContactUserSummaryDto contact;

  @override
  State<ChatMobileConversationSection> createState() =>
      _ChatMobileConversationSectionState();
}

class _ChatMobileConversationSectionState
    extends State<ChatMobileConversationSection> {
  static const int _maxChatFileSizeBytes = 5 * 1024 * 1024;

  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UsersService _usersService = UsersService();
  final ChatFilesService _chatFilesService = ChatFilesService();
  final RealtimeChatService _realtimeChatService = RealtimeChatService();

  StreamSubscription<RealtimeChatEvent>? _chatSubscription;

  String? _myUsername;
  String? _activeChannelName;
  bool _isLoading = true;
  bool _isSendingFile = false;
  bool _isOtherOnline = false;
  String? _errorMessage;
  List<_MobileChatMessage> _messages = const <_MobileChatMessage>[];

  ContactUserSummaryDto get _contact => widget.contact;

  bool get _canInteract =>
      _contact.status.trim().toLowerCase() == 'accepted' &&
      (_contact.username?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeChat());
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var username = context.read<UserProvider>().account?.username?.trim();
      var displayName = context.read<UserProvider>().account?.fullName?.trim();

      if (username == null || username.isEmpty) {
        final me = await _usersService.getMe();
        username = me.username?.trim();
        displayName = me.displayName?.trim();
      }

      if (username == null || username.isEmpty) {
        throw Exception('Não foi possível identificar o utilizador.');
      }

      displayName = (displayName == null || displayName.isEmpty)
          ? username
          : displayName;

      _myUsername = username;
      await _realtimeChatService.connect(
        username: username,
        displayName: displayName,
      );
      await _chatSubscription?.cancel();
      _chatSubscription = _realtimeChatService.events.listen(_onChatEvent);

      if (!_canInteract) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final otherUsername = _contact.username!.trim();
      _activeChannelName = await _realtimeChatService.joinDirectMessage(
        otherUsername: otherUsername,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
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

    if (event is RealtimeChatMessageReceived ||
        event is RealtimeChatDirectMessageReceived) {
      final message = event is RealtimeChatMessageReceived
          ? event.message
          : (event as RealtimeChatDirectMessageReceived).message;
      final channelName = event is RealtimeChatMessageReceived
          ? event.channelName
          : (event as RealtimeChatDirectMessageReceived).channelName;
      if (message.isSystemFileNotification) return;
      _appendMessage(channelName, message);
      final myUsername = _myUsername;
      if (myUsername != null &&
          message.senderId.trim().toLowerCase() != myUsername.toLowerCase()) {
        _markConversationRead(channelName);
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
        _isLoading = false;
        _errorMessage = event.message;
      });
    }
  }

  String? get _expectedChannel {
    final myUsername = _myUsername;
    final otherUsername = _contact.username?.trim();
    if (myUsername == null || otherUsername == null || otherUsername.isEmpty) {
      return null;
    }
    return RealtimeChatConfig.dmChannelName(myUsername, otherUsername);
  }

  void _applyRoomHistory(
    String channelName,
    List<RealtimeChatMessage> messages,
  ) {
    if (_expectedChannel != channelName) return;

    final myUsername = _myUsername;
    if (myUsername == null) return;

    final mapped =
        messages
            .map(
              (message) => _MobileChatMessage(
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
          ..sort(
            (first, second) => first.timestamp.compareTo(second.timestamp),
          );

    setState(() {
      _messages = mapped;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _appendMessage(String channelName, RealtimeChatMessage message) {
    if (_expectedChannel != channelName) return;

    final myUsername = _myUsername;
    if (myUsername == null) return;

    final mapped = _MobileChatMessage(
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

    setState(() {
      final next = List<_MobileChatMessage>.from(_messages);
      final alreadyExists = next.any((item) => item.id == mapped.id);
      if (!alreadyExists) {
        next.add(mapped);
        next.sort(
          (first, second) => first.timestamp.compareTo(second.timestamp),
        );
        _messages = next;
      }
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _applyMessagesRead(String channelName, List<String> messageIds) {
    if (_expectedChannel != channelName) return;
    final ids = messageIds
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return;

    setState(() {
      _messages = _messages
          .map((message) {
            if (!message.isOutgoing ||
                message.isRead ||
                !ids.contains(message.id)) {
              return message;
            }
            return message.copyWith(isRead: true);
          })
          .toList(growable: false);
    });
  }

  void _applyPresenceFromParticipants(
    String channelName,
    List<RealtimeChatParticipant> participants,
  ) {
    if (_expectedChannel != channelName) return;
    final otherUsername = _contact.username?.trim().toLowerCase();
    if (otherUsername == null || otherUsername.isEmpty) return;

    final isOnline = participants.any(
      (participant) =>
          participant.isConnected &&
          participant.userId.trim().toLowerCase() == otherUsername,
    );

    setState(() {
      _isOtherOnline = isOnline;
    });
  }

  void _applyPresenceChange(String channelName, String userId, bool isOnline) {
    if (_expectedChannel != channelName) return;
    final otherUsername = _contact.username?.trim().toLowerCase();
    if (otherUsername == null || otherUsername.isEmpty) return;
    if (userId.trim().toLowerCase() != otherUsername) return;

    setState(() {
      _isOtherOnline = isOnline;
    });
  }

  void _markConversationRead(String channelName) {
    if (!_canInteract || _expectedChannel != channelName) return;
    _realtimeChatService.markDirectMessagesRead(channelName: channelName);
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || !_canInteract) return;

    final channelName = _activeChannelName;
    if (channelName == null || channelName.isEmpty) return;

    try {
      await _realtimeChatService.sendMessage(
        channelName: channelName,
        content: text,
      );
      if (!mounted) return;
      _composerController.clear();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _pickAndSendFile() async {
    if (!_canInteract) return;

    final channelName = _activeChannelName;
    final username = _myUsername;
    if (channelName == null || channelName.isEmpty || username == null) return;

    setState(() {
      _isSendingFile = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isSendingFile = false;
        });
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
      setState(() {
        _isSendingFile = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSendingFile = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  bool _isSameCalendarDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatDayLabel(DateTime value) {
    final localValue = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final currentDay = DateTime(
      localValue.year,
      localValue.month,
      localValue.day,
    );

    if (currentDay == today) {
      return 'Hoje';
    }

    if (currentDay == yesterday) {
      return 'Ontem';
    }

    const months = <String>[
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return '${localValue.day.toString().padLeft(2, '0')} ${months[localValue.month - 1]} ${localValue.year}';
  }

  List<_ChatTimelineEntry> _timelineEntries() {
    final entries = <_ChatTimelineEntry>[];
    DateTime? previousDate;

    for (final message in _messages) {
      final currentDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      if (previousDate == null ||
          !_isSameCalendarDay(previousDate, currentDate)) {
        entries.add(
          _ChatTimelineDayEntry(label: _formatDayLabel(message.timestamp)),
        );
        previousDate = currentDate;
      }

      entries.add(_ChatTimelineMessageEntry(message: message));
    }

    return entries;
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
      default:
        return 'application/octet-stream';
    }
  }

  String _displayName() {
    final displayName = _contact.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final username = _contact.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Utilizador';
  }

  String _initials() {
    final parts = _displayName()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Color _avatarColor() {
    final normalized =
        (_contact.contactUserId + (_contact.username ?? '')).hashCode;
    const palette = <Color>[
      Color(0xFFFF6900),
      Color(0xFF2B7FFF),
      Color(0xFF12B76A),
      Color(0xFF7A5AF8),
    ];
    return palette[normalized.abs() % palette.length];
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    _chatSubscription?.cancel();
    _realtimeChatService.disconnect();
    _realtimeChatService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = _contact.username?.trim() ?? '';
    final composerEnabled = _canInteract && !_isLoading;
    final hintText = _canInteract
        ? 'Escreva uma mensagem...'
        : 'Chat indisponível para este contacto.';
    final timelineEntries = _timelineEntries();

    return Column(
      children: [
        ChatsMobileConversationHeader(
          name: _displayName(),
          username: username,
          photoUrl: _contact.profileImageUrl,
          initials: _initials(),
          avatarColor: _avatarColor(),
          isOnline: _isOtherOnline,
          onBackTap: () => Navigator.of(context).pop(),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: ChatsConstants.backgroundColor,
                  child: _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _canInteract
                                  ? 'Ainda não existem mensagens nesta conversa.'
                                  : 'Este chat ainda não está disponível. Quando o contacto aceitar, a conversa aparece aqui.',
                              textAlign: TextAlign.center,
                              style: ChatsConstants.mobileBodyStyle,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: timelineEntries.length,
                          itemBuilder: (context, index) {
                            final entry = timelineEntries[index];
                            if (entry is _ChatTimelineDayEntry) {
                              return _ChatDayDivider(label: entry.label);
                            }

                            final message =
                                (entry as _ChatTimelineMessageEntry).message;
                            return ChatsMobileMessageBubble(
                              text: message.text,
                              timeLabel: _formatTime(message.timestamp),
                              isOutgoing: message.isOutgoing,
                              isRead: message.isRead,
                              attachment: message.attachment,
                              onOpenAttachment: _openExternalUrl,
                            );
                          },
                        ),
                ),
        ),
        ChatsMobileComposer(
          controller: _composerController,
          enabled: composerEnabled,
          hintText: hintText,
          isSendingFile: _isSendingFile,
          onSend: _sendMessage,
          onPickFile: _pickAndSendFile,
        ),
      ],
    );
  }
}

abstract class _ChatTimelineEntry {
  const _ChatTimelineEntry();
}

class _ChatTimelineDayEntry extends _ChatTimelineEntry {
  const _ChatTimelineDayEntry({required this.label});

  final String label;
}

class _ChatTimelineMessageEntry extends _ChatTimelineEntry {
  const _ChatTimelineMessageEntry({required this.message});

  final _MobileChatMessage message;
}

class _ChatDayDivider extends StatelessWidget {
  const _ChatDayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ChatsConstants.mobileBorderColor),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ChatsConstants.mobileMutedColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileChatMessage {
  const _MobileChatMessage({
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

  _MobileChatMessage copyWith({bool? isRead}) {
    return _MobileChatMessage(
      id: id,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isOutgoing: isOutgoing,
      isRead: isRead ?? this.isRead,
      attachment: attachment,
    );
  }
}
