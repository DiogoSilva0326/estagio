import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  static const String baseUrl = 'http://localhost:8082/api';
  
  // Login user
  static Future<LoginResponse> login({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        return LoginResponse(
          success: false,
          message: 'Failed to login: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Send message
  static Future<SendMessageResponse> sendMessage({
    required String userId,
    required String to,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'to': to,
          'message': message,
          'messageType': 'txt',
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SendMessageResponse.fromJson(jsonResponse);
      } else {
        return SendMessageResponse(
          success: false,
          message: 'Failed to send message: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SendMessageResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get messages
  static Future<List<ChatMessage>> getMessages({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] as List;
        return data.map((m) => ChatMessage.fromJson(m)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Logout
  static Future<bool> logout({
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/logout?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Response Models
class LoginResponse {
  final bool success;
  final String message;
  final String? userId;
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.userId,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['data']?['userId'],
      token: json['data']?['token'],
    );
  }
}

class SendMessageResponse {
  final bool success;
  final String message;
  final String? messageId;

  SendMessageResponse({
    required this.success,
    required this.message,
    this.messageId,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      messageId: json['data']?['messageId'],
    );
  }
}

class ChatMessage {
  final String messageId;
  final String from;
  final String to;
  final String content;
  final String type;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.from,
    required this.to,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'txt',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
