import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

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
}

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
}

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

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String get _hubUrl {
    final baseUrl = ApiConfig.baseUrl; 
    final cleanBase = baseUrl.endsWith('/api') 
        ? baseUrl.substring(0, baseUrl.length - 4) 
        : baseUrl;
    return '$cleanBase/chathub';
  }

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

    print('🟢 TENTATIVA DE LIGAÇÃO SIGNALR: $_hubUrl'); // <-- VAI IMPRIMIR O URL

    try {
      _channelName = channelName;
      _userId = userId;
      _displayName = displayName;

      final token = await TokenStorage().loadToken();
      print('🟢 TOKEN OBTIDO: ${token != null ? "Sim" : "Não"}');

      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl, options: HttpConnectionOptions(
             accessTokenFactory: () async => token ?? '',
          ))
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on('RoomJoined', _onRoomJoined);
      _hubConnection!.on('MessageReceived', _onMessageReceived);

      _hubConnection!.onclose(({Exception? error}) {
        _isConnected = false;
        _error = error?.toString();
        print('🔴 LIGAÇÃO SIGNALR FECHADA/CAIU: $_error');
        _safeNotifyListeners();
      });

      print('🟢 A INICIAR HUB...');
      await _hubConnection!.start();
      print('🟢 HUB INICIADO COM SUCESSO! A ENTRAR NA SALA...');
      
      await _hubConnection!.invoke('JoinRoom', args: [channelName, userId, displayName]);
      print('🟢 ENTROU NA SALA!');

      _isConnected = true;
      _isConnecting = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isConnecting = false;
      _isConnected = false;
      _safeNotifyListeners();
      
      print('🔴 ERRO GRAVE AO LIGAR SIGNALR: $e'); // <-- VAI IMPRIMIR O MOTIVO DA FALHA
      return false;
    }
  }

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
    _messages.clear();
    if (!_disposed) {
      _safeNotifyListeners();
    }
  }

  Future<bool> sendMessage(String content) async {
    if (!_isConnected || content.trim().isEmpty) return false;

    try {
      await _hubConnection!.invoke('SendMessage', args: [_channelName, _userId, content.trim()]);
      return true;
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  void _onRoomJoined(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final messagesData = data['messages'] as List<dynamic>? ?? [];
    _messages.clear();
    for (final m in messagesData) {
      if (m is Map<String, dynamic>) {
        _messages.add(ChatMessage.fromJson(m));
      }
    }
    _safeNotifyListeners();
  }

  void _onMessageReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final data = args[0] as Map<String, dynamic>?;
    if (data != null) {
      _messages.add(ChatMessage.fromJson(data));
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}