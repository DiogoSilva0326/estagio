import 'dart:async';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Serviço que usa o SDK Agora Chat diretamente
/// Baseado na lógica do Chat-Web oficial da Agora
class AgoraChatSDKService {
  static const String appKey = "411427678#1628083";
  static const String loginEndpoint = "https://a41.chat.agora.io/app/chat/user/login";
  static const String registerEndpoint = "https://a41.chat.agora.io/app/chat/user/register";
  
  late ChatClient _chatClient;
  String? _currentUserId;
  
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<String> _connectionController = StreamController<String>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  
  AgoraChatSDKService() {
    _initializeChatClient();
  }
  
  /// Inicializa o ChatClient (equivalente ao WebIM.conn no JS)
  void _initializeChatClient() {
    ChatOptions options = ChatOptions(
      appKey: appKey,
      autoLogin: false,
    );
    
    _chatClient = ChatClient.getInstance;
    _chatClient.init(options);
    
    // Register event handlers
    _chatClient.chatManager.addEventHandler(
      'chat_handler',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          for (var msg in messages) {
            _messageController.add(msg);
          }
        },
      ),
    );
    
    // Connection event handlers
    _chatClient.addConnectionEventHandler(
      'connection_handler',
      ConnectionEventHandler(
        onConnected: () {
          print('✅ Connected to Agora Chat');
          _connectionController.add('connected');
        },
        onDisconnected: () {
          print('📌 Disconnected from Agora Chat');
          _connectionController.add('disconnected');
        },
        onTokenWillExpire: () {
          print('⚠️ Token will expire, refreshing...');
          if (_currentUserId != null) {
            _refreshToken(_currentUserId!);
          }
        },
        onTokenDidExpire: () {
          print('❌ Token expired, please login again');
          _connectionController.add('token_expired');
        },
      ),
    );
  }
  
  /// Registra novo usuário via REST API do Agora
  Future<Map<String, dynamic>> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userAccount': username,
          'userPassword': password,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ User $username registered successfully');
        return {'success': true, 'message': 'User registered successfully'};
      } else {
        print('⚠️ User $username already exists or registration failed');
        return {'success': false, 'message': 'User already exists'};
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return {'success': false, 'message': 'Registration error: $e'};
    }
  }
  
  /// Login via REST API do Agora (obter accessToken)
  /// Depois usa SDK para abrir conexão WebSocket
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Step 1: Get access token from Agora REST API
      print('🔐 Logging in user: $username');
      
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userAccount': username,
          'userPassword': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'] as String;
        final chatUserName = data['chatUserName'] as String?;
        
        // Step 2: Use SDK to open connection
        await _chatClient.loginWithToken(
          chatUserName ?? username,
          accessToken,
        );
        
        _currentUserId = chatUserName ?? username;
        
        print('✅ Login successful for $username');
        return {
          'success': true,
          'message': 'Login successful',
          'userId': _currentUserId,
          'accessToken': accessToken,
        };
      } else {
        print('❌ Login failed: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Login error: $e',
      };
    }
  }
  
  /// Refresh token quando está prestes a expirar
  Future<void> _refreshToken(String username) async {
    try {
      // Aqui você precisaria do password armazenado ou usar refresh token
      // Por simplicidade, vamos logar novamente
      print('🔄 Refreshing token for $username');
      // Implementar lógica de refresh se necessário
    } catch (e) {
      print('❌ Token refresh error: $e');
    }
  }
  
  /// Envia mensagem de texto
  Future<Map<String, dynamic>> sendTextMessage(String toUserId, String text) async {
    if (_currentUserId == null) {
      return {'success': false, 'message': 'Not logged in'};
    }
    
    try {
      ChatMessage message = ChatMessage.createTxtSendMessage(
        targetId: toUserId,
        content: text,
      );
      
      await _chatClient.chatManager.sendMessage(message);
      
      print('✅ Message sent to $toUserId: $text');
      return {
        'success': true,
        'message': 'Message sent',
        'messageId': message.msgId,
      };
    } catch (e) {
      print('❌ Send message error: $e');
      return {
        'success': false,
        'message': 'Send error: $e',
      };
    }
  }
  
  /// Recupera histórico de mensagens de uma conversa
  Future<List<ChatMessage>> fetchConversationMessages(String conversationId, {int count = 20}) async {
    try {
      ChatConversation? conversation = await _chatClient.chatManager.getConversation(conversationId);
      
      if (conversation != null) {
        List<ChatMessage> messages = await conversation.loadMessages(
          startMsgId: '',
          loadCount: count,
        );
        return messages;
      }
      return [];
    } catch (e) {
      print('❌ Fetch messages error: $e');
      return [];
    }
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      await _chatClient.logout();
      _currentUserId = null;
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }
  
  /// Limpar recursos
  void dispose() {
    _messageController.close();
    _connectionController.close();
  }
}
