import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

/// Agora Chat Web Service usando JS SDK diretamente
/// Baseado no exemplo oficial Chat-Web
class AgoraChatWebService {
  static const String appKey = "411427678#1628083";
  static const String loginEndpoint = "https://a41.chat.agora.io/app/chat/user/login";
  static const String registerEndpoint = "https://a41.chat.agora.io/app/chat/user/register";
  
  String? _currentUserId;
  
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionController = 
      StreamController<String>.broadcast();
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<String> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  
  AgoraChatWebService() {
    _initializeWebIM();
  }
  
  /// Inicializa o WebIM do Agora Chat (equivalente ao Chat-Web/src/index.js)
  void _initializeWebIM() {
    try {
      // Verifica se WebIM está disponível via JS
      final script = '''
        (function() {
          if (window.WebIM) {
            console.log('✅ WebIM found and ready');
            window.flutterWebIMReady = true;
          } else {
            console.error('❌ WebIM not found. Make sure agora-chat SDK is loaded in index.html');
            window.flutterWebIMReady = false;
          }
        })();
      ''';
      
      _executeScript(script);
      
      // Configura conexão
      _setupConnectionHandlers();
      
      print('✅ WebIM initialized');
    } catch (e) {
      print('❌ WebIM initialization error: $e');
    }
  }
  
  /// Configura handlers de conexão (onConnected, onDisconnected, etc)
  void _setupConnectionHandlers() {
    try {
      // Registra handlers via JS que disparam eventos DOM
      final script = '''
        (function() {
          if (window.WebIM && window.WebIM.conn) {
            window.WebIM.conn.addEventHandler('flutterHandler', {
              onConnected: function() {
                console.log('✅ Connected to Agora Chat');
                window.dispatchEvent(new CustomEvent('flutter_connected'));
              },
              onDisconnected: function() {
                console.log('📌 Disconnected from Agora Chat');
                window.dispatchEvent(new CustomEvent('flutter_disconnected'));
              },
              onTextMessage: function(message) {
                console.log('📨 Message received:', message);
                window.dispatchEvent(new CustomEvent('flutter_message', {
                  detail: JSON.stringify(message)
                }));
              },
              onTokenWillExpire: function() {
                console.log('⚠️ Token will expire');
                window.dispatchEvent(new CustomEvent('flutter_token_will_expire'));
              },
              onTokenExpired: function() {
                console.log('❌ Token expired');
                window.dispatchEvent(new CustomEvent('flutter_token_expired'));
              }
            });
            console.log('✅ Event handlers registered');
          }
        })();
      ''';
      
      _executeScript(script);
      
      // Escuta eventos DOM no lado Dart
      _listenToDOMEvents();
    } catch (e) {
      print('❌ Setup handlers error: $e');
    }
  }
  
  /// Escuta eventos customizados do DOM
  void _listenToDOMEvents() {
    // onConnected
    web.window.addEventListener('flutter_connected', ((web.Event event) {
      print('✅ Connected to Agora Chat');
      _connectionController.add('connected');
    }).toJS);
    
    // onDisconnected
    web.window.addEventListener('flutter_disconnected', ((web.Event event) {
      print('📌 Disconnected from Agora Chat');
      _connectionController.add('disconnected');
    }).toJS);
    
    // onTextMessage
    web.window.addEventListener('flutter_message', ((web.Event event) {
      try {
        final customEvent = event as web.CustomEvent;
        final detail = customEvent.detail;
        // Aqui precisamos converter JSAny para String
        final messageStr = (detail as JSString).toDart;
        final message = jsonDecode(messageStr);
        _messageController.add(message);
        print('📨 Message received in Dart: ${message['data']}');
      } catch (e) {
        print('❌ Message parse error: $e');
      }
    }).toJS);
    
    // onTokenWillExpire
    web.window.addEventListener('flutter_token_will_expire', ((web.Event event) {
      print('⚠️ Token will expire');
      _connectionController.add('token_will_expire');
    }).toJS);
    
    // onTokenExpired
    web.window.addEventListener('flutter_token_expired', ((web.Event event) {
      print('❌ Token expired');
      _connectionController.add('token_expired');
    }).toJS);
  }
  
  /// Executa código JavaScript no navegador
  void _executeScript(String script) {
    final scriptElement = web.document.createElement('script') as web.HTMLScriptElement;
    scriptElement.text = script;
    web.document.head!.appendChild(scriptElement);
  }
  
  /// Registra novo usuário
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
        return {
          'success': true,
          'message': 'Registration successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['errorInfo'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Register error: $e',
      };
    }
  }
  
  /// Login com username/password (equivalente ao Chat-Web postData + WebIM.conn.open)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Step 1: POST para obter accessToken
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
        
        final userId = chatUserName ?? username;
        
        // Step 2: Chama WebIM.conn.open via JS
        final script = '''
          (function() {
            if (window.WebIM && window.WebIM.conn) {
              window.WebIM.conn.open({
                user: '$userId',
                accessToken: '$accessToken'
              });
              console.log('✅ WebIM.conn.open called for user: $userId');
            } else {
              console.error('❌ WebIM.conn not available');
            }
          })();
        ''';
        
        _executeScript(script);
        _currentUserId = userId;
        
        print('✅ Login successful for $username');
        return {
          'success': true,
          'message': 'Login successful',
          'userId': userId,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['errorInfo'] ?? 'Login failed',
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
  
  /// Envia mensagem de texto
  Future<Map<String, dynamic>> sendTextMessage(String toUserId, String text) async {
    if (_currentUserId == null) {
      return {
        'success': false,
        'message': 'Not logged in',
      };
    }
    
    try {
      // Cria mensagem via WebIM.conn.sendTextMessage
      final script = '''
        (function() {
          if (window.WebIM && window.WebIM.conn) {
            var msg = new window.WebIM.message('txt', Date.now().toString());
            msg.set({
              msg: '$text',
              to: '$toUserId',
              chatType: 'singleChat',
              success: function(id, serverMsgId) {
                console.log('✅ Message sent:', serverMsgId);
              },
              fail: function(e) {
                console.error('❌ Send message failed:', e);
              }
            });
            window.WebIM.conn.send(msg.body);
          }
        })();
      ''';
      
      _executeScript(script);
      
      return {
        'success': true,
        'message': 'Message sent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Send error: $e',
      };
    }
  }
  
  /// Logout
  Future<void> logout() async {
    try {
      final script = '''
        (function() {
          if (window.WebIM && window.WebIM.conn) {
            window.WebIM.conn.close();
            console.log('✅ Logged out');
          }
        })();
      ''';
      
      _executeScript(script);
      _currentUserId = null;
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }
  
  void dispose() {
    _messageController.close();
    _connectionController.close();
  }
}
