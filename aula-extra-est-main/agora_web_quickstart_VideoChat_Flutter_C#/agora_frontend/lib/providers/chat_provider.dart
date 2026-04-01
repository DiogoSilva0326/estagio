import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import '../services/agora_chat_web_service.dart';

class ChatProvider extends ChangeNotifier {
  final AgoraChatWebService _chatService = AgoraChatWebService();
  
  String _userId = '';
  String _password = 'Pass_user_2026'; // Default password
  String _peerId = '';
  bool _isChatLoggedIn = false;
  final List<String> _logs = [];
  final List<ChatMessage> _messages = [];

  ChatProvider() {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to incoming messages (agora web SDK format: {from, to, data, ...})
    _chatService.messageStream.listen((message) {
      addLog('Message from: ${message['from']} Message: ${message['data']}');
      notifyListeners();
    });

    // Listen to connection status
    _chatService.connectionStream.listen((status) {
      if (status == 'connected') {
        _isChatLoggedIn = true;
        addLog('Connect success!');
      } else if (status == 'disconnected') {
        _isChatLoggedIn = false;
        addLog('Disconnected from chat');
      } else if (status == 'token_expired') {
        addLog('Token expired, please login again');
        _isChatLoggedIn = false;
      }
      notifyListeners();
    });
  }

  // Getters
  String get userId => _userId;
  String get password => _password;
  String get peerId => _peerId;
  bool get isChatLoggedIn => _isChatLoggedIn;
  List<String> get logs => _logs;
  List<ChatMessage> get messages => _messages;

  // Setters
  void setUserId(String value) {
    _userId = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setPeerId(String value) {
    _peerId = value;
    notifyListeners();
  }

  // Register (opcional)
  Future<bool> register() async {
    if (_userId.isEmpty || _password.isEmpty) {
      addLog('Please enter userId and password');
      return false;
    }

    try {
      final result = await _chatService.registerUser(_userId, _password);
      
      if (result['success']) {
        addLog('register user $_userId success');
        return true;
      } else {
        addLog('${result['message']}');
        return false;
      }
    } catch (e) {
      addLog('Register error: $e');
      return false;
    }
  }

  // Login usando SDK Agora direto
  Future<bool> login() async {
    if (_userId.isEmpty || _password.isEmpty) {
      addLog('Please enter userId and password');
      return false;
    }

    try {
      addLog('Logging in...');
      final result = await _chatService.login(_userId, _password);
      
      if (result['success']) {
        _isChatLoggedIn = true;
        addLog('User $_userId logged in successfully');
        notifyListeners();
        return true;
      } else {
        addLog('Login failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      addLog('Login error: $e');
      return false;
    }
  }

  // Send Message usando SDK
  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      addLog('Please enter message content');
      return false;
    }

    if (_peerId.isEmpty) {
      addLog('Please enter peer user ID');
      return false;
    }

    if (!_isChatLoggedIn) {
      addLog('Please login first');
      return false;
    }

    try {
      final result = await _chatService.sendTextMessage(_peerId, message);
      
      if (result['success']) {
        addLog('Message sent to $_peerId: $message');
        notifyListeners();
        return true;
      } else {
        addLog('Message send failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      addLog('Send message error: $e');
      return false;
    }
  }

  // Fetch conversation messages
  // Fetch messages não disponível na versão web SDK simplificada
  // Mensagens chegam via messageStream em tempo real
  Future<void> fetchMessages() async {
    addLog('Messages are received in real-time via WebSocket');
  }

  // Logout
  Future<void> logout() async {
    try {
      await _chatService.logout();
      _isChatLoggedIn = false;
      _userId = '';
      _password = '';
      _peerId = '';
      _messages.clear();
      addLog('Logout successful');
      notifyListeners();
    } catch (e) {
      addLog('Logout error: $e');
    }
  }

  // Add log
  void addLog(String log) {
    _logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
    notifyListeners();
  }

  // Clear logs
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
