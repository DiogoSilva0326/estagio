import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:aula_extra/core/data/http/api_config.dart';

class RealtimeChatConfig {
  static const String _configuredHubBaseUrl = String.fromEnvironment(
    'CHAT_HUB_BASE_URL',
    defaultValue: '',
  );
  static const String _localHubBaseUrl = 'http://localhost:5050';
  static const String _defaultRemoteHubBaseUrl = 'https://aulaextra-agora.synget.ovh';

  static String hubBaseUrl() {
    final configured = _normalizeBaseUrl(_configuredHubBaseUrl);
    if (configured.isNotEmpty) {
      return configured;
    }

    if (_isLocalUrl(ApiConfig.baseUrl)) {
      return _localHubBaseUrl;
    }

    return _defaultRemoteHubBaseUrl;
  }

  static String hubUrl() {
    final base = hubBaseUrl();
    return '$base/chathub';
  }

  static String? resolveHttpUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    return ApiConfig.uri(raw).toString();
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  static bool _isLocalUrl(String value) {
    final uri = Uri.tryParse(value);
    final host = uri?.host.toLowerCase() ?? '';

    return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
  }

  static String dmChannelName(String userA, String userB) {
    final sorted = [normalizeUsername(userA), normalizeUsername(userB)]..sort();
    return 'dm_${sorted[0]}_${sorted[1]}';
  }

  static String normalizeUsername(String value) {
    return value.trim().toLowerCase();
  }
}
//Commnet
class RealtimeChatMessage {
  const RealtimeChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.readAt,
    this.attachment,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final RealtimeChatAttachment? attachment;

  bool get isFileMessage => type.toLowerCase() == 'file' && attachment != null;

  bool get isSystemFileNotification =>
      type.toLowerCase() == 'text' &&
      attachment == null &&
      content.startsWith('📎 Ficheiro enviado:');

  factory RealtimeChatMessage.fromJson(Map<String, dynamic> json) {
    final tsRaw = json['timestamp']?.toString();
    DateTime ts;
    try {
      ts = tsRaw != null && tsRaw.isNotEmpty ? DateTime.parse(tsRaw) : DateTime.now();
    } catch (_) {
      ts = DateTime.now();
    }

    final isReadRaw = json['isRead'];
    final isRead = isReadRaw is bool ? isReadRaw : (isReadRaw?.toString().toLowerCase() == 'true');

    final readAtRaw = json['readAt']?.toString();
    DateTime? readAt;
    if (readAtRaw != null && readAtRaw.isNotEmpty) {
      try {
        readAt = DateTime.parse(readAtRaw);
      } catch (_) {
        readAt = null;
      }
    }

    RealtimeChatAttachment? attachment;
    final rawAttachment = json['attachment'];
    if (rawAttachment is Map) {
      final attachmentMap = Map<String, dynamic>.from(rawAttachment);
      final nestedAttachment = attachmentMap['attachment'];
      if (nestedAttachment is Map) {
        attachment = RealtimeChatAttachment.fromJson(
          Map<String, dynamic>.from(nestedAttachment),
        );
      } else {
        attachment = RealtimeChatAttachment.fromJson(attachmentMap);
      }
    }

    return RealtimeChatMessage(
      messageId: json['messageId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: ts,
      type: json['type']?.toString() ?? 'text',
      isRead: isRead,
      readAt: readAt,
      attachment: attachment,
    );
  }
}

class RealtimeChatAttachment {
  const RealtimeChatAttachment({
    required this.fileId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.downloadUrl,
    this.thumbnailUrl,
  });

  final String fileId;
  final String fileName;
  final String contentType;
  final int fileSize;
  final String downloadUrl;
  final String? thumbnailUrl;

  factory RealtimeChatAttachment.fromJson(Map<String, dynamic> json) {
    return RealtimeChatAttachment(
      fileId: json['fileId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      fileSize: _parseAttachmentInt(json['fileSize']),
      downloadUrl: RealtimeChatConfig.resolveHttpUrl(
            json['downloadUrl']?.toString(),
          ) ??
          '',
      thumbnailUrl: RealtimeChatConfig.resolveHttpUrl(
        json['thumbnailUrl']?.toString(),
      ),
    );
  }
}

sealed class RealtimeChatEvent {
  const RealtimeChatEvent();
}

class RealtimeChatRoomJoined extends RealtimeChatEvent {
  const RealtimeChatRoomJoined({
    required this.channelName,
    required this.messages,
    required this.participants,
  });

  final String channelName;
  final List<RealtimeChatMessage> messages;
  final List<RealtimeChatParticipant> participants;
}

class RealtimeChatParticipant {
  const RealtimeChatParticipant({
    required this.userId,
    required this.displayName,
    required this.isConnected,
  });

  final String userId;
  final String displayName;
  final bool isConnected;

  factory RealtimeChatParticipant.fromJson(Map<String, dynamic> json) {
    final raw = json['isConnected'];
    final isConnected = raw is bool ? raw : (raw?.toString().toLowerCase() == 'true');
    return RealtimeChatParticipant(
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      isConnected: isConnected,
    );
  }
}

class RealtimeChatMessageReceived extends RealtimeChatEvent {
  const RealtimeChatMessageReceived({
    required this.channelName,
    required this.message,
  });

  final String channelName;
  final RealtimeChatMessage message;
}

class RealtimeChatDirectMessageReceived extends RealtimeChatEvent {
  const RealtimeChatDirectMessageReceived({
    required this.channelName,
    required this.message,
  });

  final String channelName;
  final RealtimeChatMessage message;
}

class RealtimeChatError extends RealtimeChatEvent {
  const RealtimeChatError(this.message);
  final String message;
}

class RealtimeChatUserPresenceChanged extends RealtimeChatEvent {
  const RealtimeChatUserPresenceChanged({
    required this.channelName,
    required this.userId,
    required this.isOnline,
  });

  final String channelName;
  final String userId;
  final bool isOnline;
}

class RealtimeChatMessagesRead extends RealtimeChatEvent {
  const RealtimeChatMessagesRead({
    required this.channelName,
    required this.readerId,
    required this.messageIds,
    required this.readAt,
  });

  final String channelName;
  final String readerId;
  final List<String> messageIds;
  final DateTime readAt;
}

class RealtimeChatService {
  HubConnection? _hub;
  String? _username;
  String? _displayName;
  String? _joinedChannel;
  String? _lastConnectionError;

  final LinkedHashSet<String> _recentMessageKeys = LinkedHashSet<String>();
  static const int _recentMessageKeysMax = 500;

  final StreamController<RealtimeChatEvent> _eventsController = StreamController.broadcast();

  Stream<RealtimeChatEvent> get events => _eventsController.stream;

  bool get isConnected => _hub?.state == HubConnectionState.Connected;

  Future<void> connect({
    required String username,
    required String displayName,
  }) async {
    _username = RealtimeChatConfig.normalizeUsername(username);
    _displayName = displayName;

    if (_hub != null && isConnected) {
      // Ensure we're in notification group.
      await _safeInvoke('JoinUserNotifications', args: <Object>[_username!]);
      return;
    }

    // If we have a hub instance but it's not connected, stop it before creating a new one.
    // This avoids having multiple active connections (and duplicated events) if connect()
    // is called repeatedly during reconnect/routing.
    if (_hub != null && !isConnected) {
      try {
        await _hub!.stop();
      } catch (_) {}
      _hub = null;
    }

    final hubUrl = RealtimeChatConfig.hubUrl();
    debugPrint('RealtimeChatService: Using hub URL $hubUrl');

    final strategies = _buildConnectionStrategies(hubUrl);
    Object? lastError;

    for (final strategy in strategies) {
      final hub = _buildHub(hubUrl, strategy.options);
      _attachHubHandlers(hub);

      try {
        debugPrint('RealtimeChatService: Connecting with ${strategy.name}');
        await hub.start();
        await hub.invoke('JoinUserNotifications', args: <Object>[_username!]);

        final channel = _joinedChannel;
        if (channel != null && channel.isNotEmpty) {
          await hub.invoke('JoinRoom', args: <Object>[channel, _username!, displayName]);
        }

        _hub = hub;
        _lastConnectionError = null;
        return;
      } catch (e) {
        lastError = e;
        _lastConnectionError = e.toString();
        debugPrint('RealtimeChatService: ${strategy.name} failed: $e');
        try {
          await hub.stop();
        } catch (_) {}
      }
    }

    _hub = null;
    final message = _formatConnectionError(lastError);
    _eventsController.add(RealtimeChatError(message));
    throw StateError(message);
  }

  Future<void> disconnect() async {
    final hub = _hub;
    if (hub == null) return;

    final channel = _joinedChannel;
    if (channel != null && channel.isNotEmpty) {
      await _safeInvoke('LeaveRoom', args: <Object>[channel]);
    }

    try {
      await hub.stop();
    } catch (_) {}

    _hub = null;
    _joinedChannel = null;
    _lastConnectionError = null;
  }

  List<_ConnectionStrategy> _buildConnectionStrategies(String hubUrl) {
    final useRemoteStrategies = !_isLocalHubUrl(hubUrl);

    if (!useRemoteStrategies) {
      return <_ConnectionStrategy>[
        _ConnectionStrategy(
          name: 'default SignalR transport negotiation',
          options: HttpConnectionOptions(requestTimeout: 15000),
        ),
      ];
    }

    if (kIsWeb) {
      return <_ConnectionStrategy>[
        _ConnectionStrategy(
          name: 'WebSockets with negotiation',
          options: HttpConnectionOptions(
            transport: HttpTransportType.WebSockets,
            requestTimeout: 15000,
          ),
        ),
        _ConnectionStrategy(
          name: 'LongPolling fallback for web',
          options: HttpConnectionOptions(
            transport: HttpTransportType.LongPolling,
            requestTimeout: 15000,
          ),
        ),
        _ConnectionStrategy(
          name: 'default SignalR transport negotiation',
          options: HttpConnectionOptions(requestTimeout: 15000),
        ),
      ];
    }

    return <_ConnectionStrategy>[
      _ConnectionStrategy(
        name: 'WebSockets with skipped negotiation',
        options: HttpConnectionOptions(
          transport: HttpTransportType.WebSockets,
          skipNegotiation: true,
          requestTimeout: 15000,
        ),
      ),
      _ConnectionStrategy(
        name: 'WebSockets with negotiation',
        options: HttpConnectionOptions(
          transport: HttpTransportType.WebSockets,
          requestTimeout: 15000,
        ),
      ),
      _ConnectionStrategy(
        name: 'default SignalR transport negotiation',
        options: HttpConnectionOptions(requestTimeout: 15000),
      ),
    ];
  }

  HubConnection _buildHub(String hubUrl, HttpConnectionOptions options) {
    return HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect()
        .build();
  }

  void _attachHubHandlers(HubConnection hub) {
    hub.on('RoomJoined', _onRoomJoined);
    hub.on('MessageReceived', _onMessageReceived);
    hub.on('DirectMessageReceived', _onDirectMessageReceived);
    hub.on('UserJoined', _onUserJoined);
    hub.on('UserLeft', _onUserLeft);
    hub.on('MessagesRead', _onMessagesRead);
    hub.on('Error', _onError);

    hub.onclose(({Exception? error}) {
      if (error == null) {
        return;
      }

      _lastConnectionError = error.toString();
      debugPrint('RealtimeChatService: connection closed: $error');
      _eventsController.add(RealtimeChatError(_formatConnectionError(error)));
    });

    hub.onreconnecting(({Exception? error}) {
      if (error == null) {
        return;
      }

      _lastConnectionError = error.toString();
      debugPrint('RealtimeChatService: reconnecting: $error');
      _eventsController.add(RealtimeChatError(_formatConnectionError(error)));
    });

    hub.onreconnected(({String? connectionId}) {
      final u = _username;
      if (u != null) {
        _safeInvoke('JoinUserNotifications', args: <Object>[u]);
      }
      final channel = _joinedChannel;
      final dn = _displayName;
      if (u != null && dn != null && channel != null && channel.isNotEmpty) {
        _safeInvoke('JoinRoom', args: <Object>[channel, u, dn]);
      }
    });
  }

  bool _isLocalHubUrl(String hubUrl) {
    final uri = Uri.tryParse(hubUrl);
    final host = uri?.host.toLowerCase() ?? '';

    return host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0';
  }

  String _formatConnectionError(Object? error) {
    final raw = error?.toString().trim();
    final message = (raw == null || raw.isEmpty) ? (_lastConnectionError ?? 'Erro ao ligar ao chat em tempo real.') : raw;
    final normalized = message.toLowerCase();

    if (normalized.contains('handshake') || normalized.contains('websocket') || normalized.contains('connection was closed')) {
      return 'Não foi possível estabelecer a ligação em tempo real ao chat (`${RealtimeChatConfig.hubBaseUrl()}`).';
    }

    return message;
  }

  Future<String> joinDirectMessage({required String otherUsername}) async {
    final u = _username;
    final dn = _displayName;

    if (u == null || dn == null) {
      throw StateError('Chat hub not connected');
    }

    if (!isConnected) {
      await connect(username: u, displayName: dn);
    }

    final hub = _hub;
    if (hub == null || !isConnected) {
      throw StateError('Chat hub not connected');
    }

    final normalizedOtherUsername = RealtimeChatConfig.normalizeUsername(otherUsername);
    final channelName = RealtimeChatConfig.dmChannelName(u, normalizedOtherUsername);

    if (_joinedChannel != null && _joinedChannel != channelName) {
      await _safeInvoke('LeaveRoom', args: <Object>[_joinedChannel!]);
    }

    _joinedChannel = channelName;
    await hub.invoke('JoinRoom', args: <Object>[channelName, u, dn]);

    return channelName;
  }

  Future<void> sendMessage({required String channelName, required String content}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    await _ensureConnectedToChannel(channelName);

    try {
      await _hub!.invoke('SendMessage', args: <Object>[channelName, trimmed]);
    } catch (_) {
      await _ensureConnectedToChannel(channelName, forceReconnect: true);
      await _hub!.invoke('SendMessage', args: <Object>[channelName, trimmed]);
    }
  }

  Future<void> sendFileMessage({
    required String channelName,
    required String fileId,
    String? caption,
  }) async {
    await _ensureConnectedToChannel(channelName);

    final normalizedCaption = caption?.trim();
    final args = <Object>[
      channelName,
      fileId,
      (normalizedCaption == null || normalizedCaption.isEmpty)
          ? ''
          : normalizedCaption,
    ];

    try {
      await _hub!.invoke('SendFileMessage', args: args);
    } catch (_) {
      await _ensureConnectedToChannel(channelName, forceReconnect: true);
      await _hub!.invoke('SendFileMessage', args: args);
    }
  }

  Future<void> markDirectMessagesRead({required String channelName}) async {
    if (channelName.trim().isEmpty) return;
    await _safeInvoke('MarkDirectMessagesRead', args: <Object>[channelName]);
  }

  Future<void> _ensureConnectedToChannel(String channelName, {bool forceReconnect = false}) async {
    final username = _username;
    final displayName = _displayName;
    if (username == null || displayName == null) {
      throw StateError('Chat hub not connected');
    }

    if (forceReconnect || !isConnected || _hub == null) {
      await connect(username: username, displayName: displayName);
    }

    final normalizedTarget = channelName.trim().toLowerCase();
    final normalizedJoined = _joinedChannel?.trim().toLowerCase();

    if (normalizedJoined != normalizedTarget) {
      _joinedChannel = channelName;
      await _hub!.invoke('JoinRoom', args: <Object>[channelName, username, displayName]);
      return;
    }

    await _safeInvoke('JoinRoom', args: <Object>[channelName, username, displayName]);
  }

  Future<void> _safeInvoke(String method, {List<Object>? args}) async {
    final hub = _hub;
    if (hub == null) return;

    try {
      await hub.invoke(method, args: args);
    } catch (e) {
      debugPrint('RealtimeChatService invoke $method failed: $e');
    }
  }

  void _onRoomJoined(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    final channelName = map['channelName']?.toString() ?? _joinedChannel ?? '';

    final rawMessages = map['messages'];
    final list = rawMessages is List ? rawMessages : const [];

    final messages = <RealtimeChatMessage>[];
    for (final item in list) {
      if (item is Map) {
        messages.add(RealtimeChatMessage.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final rawParticipants = map['participants'];
    final plist = rawParticipants is List ? rawParticipants : const [];
    final participants = <RealtimeChatParticipant>[];
    for (final item in plist) {
      if (item is Map) {
        participants.add(RealtimeChatParticipant.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    _eventsController.add(
      RealtimeChatRoomJoined(
        channelName: channelName,
        messages: messages,
        participants: participants,
      ),
    );
  }

  void _onUserJoined(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final userId = map['userId']?.toString() ?? '';
    if (userId.isEmpty) return;

    _eventsController.add(
      RealtimeChatUserPresenceChanged(
        channelName: _joinedChannel ?? '',
        userId: userId,
        isOnline: true,
      ),
    );
  }

  void _onUserLeft(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final userId = map['userId']?.toString() ?? '';
    if (userId.isEmpty) return;

    _eventsController.add(
      RealtimeChatUserPresenceChanged(
        channelName: _joinedChannel ?? '',
        userId: userId,
        isOnline: false,
      ),
    );
  }

  void _onMessageReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;

    final map = Map<String, dynamic>.from(data);
    final message = RealtimeChatMessage.fromJson(map);
    final channelName = map['channelName']?.toString() ?? _joinedChannel ?? '';

    if (_isDuplicate(_dedupeKey(channelName, message))) return;

    _eventsController.add(RealtimeChatMessageReceived(channelName: channelName, message: message));
  }

  void _onDirectMessageReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    final channelName = map['channelName']?.toString() ?? '';
    final msgRaw = map['message'];
    if (msgRaw is! Map) return;

    final message = RealtimeChatMessage.fromJson(Map<String, dynamic>.from(msgRaw));

    if (_isDuplicate(_dedupeKey(channelName, message))) return;

    _eventsController.add(RealtimeChatDirectMessageReceived(channelName: channelName, message: message));
  }

  String _dedupeKey(String channelName, RealtimeChatMessage message) {
    final msgId = message.messageId.trim();
    if (msgId.isNotEmpty) return msgId;

    final ts = message.timestamp.toUtc().toIso8601String();
    return '${message.senderId}|$ts|${message.type}|${message.content}';
  }

  bool _isDuplicate(String key) {
    if (key.isEmpty) return false;

    final wasNew = _recentMessageKeys.add(key);
    if (!wasNew) return true;

    while (_recentMessageKeys.length > _recentMessageKeysMax) {
      _recentMessageKeys.remove(_recentMessageKeys.first);
    }

    return false;
  }

  void _onError(List<Object?>? args) {
    final msg = (args != null && args.isNotEmpty) ? args.first?.toString() : null;
    _eventsController.add(RealtimeChatError(msg ?? 'Erro no chat'));
  }

  void _onMessagesRead(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    final data = args.first;
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    final channelName = map['channelName']?.toString() ?? '';
    final readerId = map['readerId']?.toString() ?? '';
    final readAtRaw = map['readAt']?.toString();
    if (channelName.isEmpty || readerId.isEmpty || readAtRaw == null || readAtRaw.isEmpty) return;

    DateTime readAt;
    try {
      readAt = DateTime.parse(readAtRaw);
    } catch (_) {
      return;
    }

    final rawIds = map['messageIds'];
    final idsList = rawIds is List ? rawIds : const [];
    final messageIds = <String>[];
    for (final item in idsList) {
      final id = item?.toString().trim() ?? '';
      if (id.isNotEmpty) messageIds.add(id);
    }

    if (messageIds.isEmpty) return;

    _eventsController.add(
      RealtimeChatMessagesRead(
        channelName: channelName,
        readerId: readerId,
        messageIds: messageIds,
        readAt: readAt,
      ),
    );
  }

  void dispose() {
    _eventsController.close();
  }
}

class _ConnectionStrategy {
  const _ConnectionStrategy({required this.name, required this.options});

  final String name;
  final HttpConnectionOptions options;
}

int _parseAttachmentInt(Object? value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
