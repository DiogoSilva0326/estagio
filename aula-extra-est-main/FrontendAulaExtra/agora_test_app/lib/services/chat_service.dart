import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Represents a file attachment in a message.
class ChatFileAttachment {
  final String fileId;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String downloadUrl;

  ChatFileAttachment({
    required this.fileId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.downloadUrl,
  });

  factory ChatFileAttachment.fromJson(Map<String, dynamic> json) {
    return ChatFileAttachment(
      fileId: json['fileId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileType: json['contentType'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }

  bool get isImage => fileType.startsWith('image/');
  bool get isVideo => fileType.startsWith('video/');
  bool get isAudio => fileType.startsWith('audio/');
  
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Represents a chat message.
class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type;
  final ChatFileAttachment? fileAttachment;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    this.fileAttachment,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      type: json['type'] as String? ?? 'text',
      fileAttachment: json['attachment'] != null 
          ? ChatFileAttachment.fromJson(json['attachment'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSystem => type == 'system';
  bool get hasFile => fileAttachment != null;
}

/// Represents a chat participant.
class ChatParticipant {
  final String userId;
  final String displayName;
  final bool isConnected;

  ChatParticipant({
    required this.userId,
    required this.displayName,
    required this.isConnected,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }
}

/// Service for real-time chat using SignalR.
class ChatService extends ChangeNotifier {
  HubConnection? _hubConnection;
  
  String _channelName = '';
  String _userId = '';
  String _displayName = '';
  
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _disposed = false;
  String? _error;
  
  final List<ChatMessage> _messages = [];
  final List<ChatParticipant> _participants = [];
  final Map<String, bool> _typingUsers = {};

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatParticipant> get participants => List.unmodifiable(_participants);
  Map<String, bool> get typingUsers => Map.unmodifiable(_typingUsers);
  String get channelName => _channelName;

  /// Safely notify listeners, checking for disposed state first.
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String get _hubUrl {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5050';
    final cleanBase = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    return '$cleanBase/chathub';
  }

  /// Connect to a chat room.
  Future<bool> connect({
    required String channelName,
    required String userId,
    required String displayName,
  }) async {
    if (_isConnecting || _isConnected) {
      if (_channelName == channelName) return true;
      await disconnect();
    }

    _isConnecting = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _channelName = channelName;
      _userId = userId;
      _displayName = displayName;

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl)
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _hubConnection!.on('RoomJoined', _onRoomJoined);
      _hubConnection!.on('MessageReceived', _onMessageReceived);
      _hubConnection!.on('UserJoined', _onUserJoined);
      _hubConnection!.on('UserLeft', _onUserLeft);
      _hubConnection!.on('UserTyping', _onUserTyping);
      _hubConnection!.on('Participants', _onParticipants);
      _hubConnection!.on('History', _onHistory);
      _hubConnection!.on('Error', _onError);

      _hubConnection!.onclose(({Exception? error}) {
        _isConnected = false;
        _error = error?.toString();
        _safeNotifyListeners();
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
        _isConnected = false;
        _safeNotifyListeners();
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
        _isConnected = true;
        // Rejoin room after reconnect
        _hubConnection!.invoke('JoinRoom', args: [_channelName, _userId, _displayName]);
        _safeNotifyListeners();
      });

      await _hubConnection!.start();
      debugPrint('ChatService: HubConnection started');
      
      // Join the room
      debugPrint('ChatService: Invoking JoinRoom for channel=$channelName, userId=$userId');
      await _hubConnection!.invoke('JoinRoom', args: [channelName, userId, displayName]);
      debugPrint('ChatService: JoinRoom invoked successfully');

      _isConnected = true;
      _isConnecting = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isConnecting = false;
      _isConnected = false;
      _safeNotifyListeners();
      debugPrint('ChatService connect error: $e');
      return false;
    }
  }

  /// Disconnect from the chat.
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        if (_isConnected && _channelName.isNotEmpty) {
          await _hubConnection!.invoke('LeaveRoom', args: [_channelName]);
        }
      } catch (_) {}
      
      try {
        await _hubConnection!.stop();
      } catch (_) {}
      
      _hubConnection = null;
    }

    _isConnected = false;
    _isConnecting = false;
    _channelName = '';
    _userId = '';
    _displayName = '';
    _messages.clear();
    _participants.clear();
    _typingUsers.clear();
    _error = null;
    if (!_disposed) {
      _safeNotifyListeners();
    }
  }

  /// Send a message.
  Future<bool> sendMessage(String content) async {
    debugPrint('ChatService: sendMessage called with content: $content');
    debugPrint('ChatService: isConnected=$_isConnected, channelName=$_channelName');
    
    if (!_isConnected || content.trim().isEmpty) {
      debugPrint('ChatService: sendMessage - not connected or empty content');
      return false;
    }

    try {
      debugPrint('ChatService: invoking SendMessage on hub');
      await _hubConnection!.invoke('SendMessage', args: [_channelName, content.trim()]);
      debugPrint('ChatService: SendMessage invoked successfully');
      return true;
    } catch (e) {
      debugPrint('ChatService: SendMessage error: $e');
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  /// Send a file message.
  Future<bool> sendFileMessage(String fileId, String? caption) async {
    debugPrint('ChatService: sendFileMessage called - fileId=$fileId, caption=$caption, connected=$_isConnected');
    if (!_isConnected || fileId.isEmpty) {
      debugPrint('ChatService: sendFileMessage - not connected or empty fileId');
      return false;
    }

    try {
      debugPrint('ChatService: invoking SendFileMessage on hub');
      await _hubConnection!.invoke('SendFileMessage', args: [_channelName, fileId, caption ?? '']);
      debugPrint('ChatService: SendFileMessage invoked successfully');
      return true;
    } catch (e) {
      debugPrint('ChatService: SendFileMessage error: $e');
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  /// Send typing indicator.
  Future<void> setTyping(bool isTyping) async {
    if (!_isConnected) return;

    try {
      await _hubConnection!.invoke('TypingIndicator', args: [_channelName, isTyping]);
    } catch (_) {}
  }

  /// Request message history.
  Future<void> getHistory({int limit = 50, String? beforeTimestamp}) async {
    if (!_isConnected) return;

    try {
      await _hubConnection!.invoke('GetHistory', args: [_channelName, limit, beforeTimestamp ?? '']);
    } catch (_) {}
  }

  // ==================== Event Handlers ====================

  void _onRoomJoined(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    // Load message history (now from database)
    final messagesData = data['messages'] as List<dynamic>? ?? [];
    _messages.clear();
    for (final m in messagesData) {
      if (m is Map<String, dynamic>) {
        _messages.add(ChatMessage.fromJson(m));
      }
    }

    // Load participants
    final participantsData = data['participants'] as List<dynamic>? ?? [];
    _participants.clear();
    for (final p in participantsData) {
      if (p is Map<String, dynamic>) {
        _participants.add(ChatParticipant.fromJson(p));
      }
    }

    // Store database user ID if available (for future use)
    final dbUserId = data['dbUserId'];
    if (dbUserId != null) {
      debugPrint('User registered in DB with ID: $dbUserId');
    }

    _safeNotifyListeners();
  }

  void _onMessageReceived(List<Object?>? args) {
    debugPrint('ChatService: MessageReceived event triggered with args: $args');
    if (args == null || args.isEmpty) {
      debugPrint('ChatService: MessageReceived - args is null or empty');
      return;
    }
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) {
      debugPrint('ChatService: MessageReceived - data is null');
      return;
    }

    debugPrint('ChatService: MessageReceived - adding message: $data');
    _messages.add(ChatMessage.fromJson(data));
    _safeNotifyListeners();
  }

  void _onUserJoined(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final userId = data['userId'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';

    // Add to participants if not already there
    if (!_participants.any((p) => p.userId == userId)) {
      _participants.add(ChatParticipant(
        userId: userId,
        displayName: displayName,
        isConnected: true,
      ));
    }

    _safeNotifyListeners();
  }

  void _onUserLeft(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final userId = data['userId'] as String? ?? '';

    _participants.removeWhere((p) => p.userId == userId);
    _typingUsers.remove(userId);
    _safeNotifyListeners();
  }

  void _onUserTyping(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final userId = data['userId'] as String? ?? '';
    final isTyping = data['isTyping'] as bool? ?? false;

    if (isTyping) {
      _typingUsers[userId] = true;
    } else {
      _typingUsers.remove(userId);
    }
    _safeNotifyListeners();
  }

  void _onParticipants(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final participantsData = data['participants'] as List<dynamic>? ?? [];
    _participants.clear();
    for (final p in participantsData) {
      if (p is Map<String, dynamic>) {
        _participants.add(ChatParticipant.fromJson(p));
      }
    }
    _safeNotifyListeners();
  }

  void _onHistory(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    // Handle both formats: direct list or object with 'messages' property
    final firstArg = args[0];
    List<dynamic> messagesData = [];
    
    if (firstArg is List) {
      messagesData = firstArg;
    } else if (firstArg is Map<String, dynamic>) {
      messagesData = firstArg['messages'] as List<dynamic>? ?? [];
    }

    // Prepend old messages (for pagination) or replace
    final oldMessages = List<ChatMessage>.from(_messages);
    _messages.clear();
    
    for (final m in messagesData) {
      if (m is Map<String, dynamic>) {
        _messages.add(ChatMessage.fromJson(m));
      }
    }
    
    _safeNotifyListeners();
  }

  void _onError(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    _error = args[0]?.toString();
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}
