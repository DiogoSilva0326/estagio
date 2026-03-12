import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionStorageService {
  static const String baseUrl = 'http://localhost:8082/api';

  // Save whiteboard snapshot
  static Future<SaveSnapshotResponse> saveWhiteboardSnapshot({
    required String channelName,
    required String imageDataBase64,
    required int pageNumber,
    required String reason,
    required List<String> activeUsers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/session/whiteboard/snapshot'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'channelName': channelName,
          'imageDataBase64': imageDataBase64,
          'pageNumber': pageNumber,
          'reason': reason,
          'activeUsers': activeUsers,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SaveSnapshotResponse.fromJson(jsonResponse);
      } else {
        return SaveSnapshotResponse(
          success: false,
          message: 'Failed to save snapshot: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SaveSnapshotResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Save chat messages
  static Future<SaveSnapshotResponse> saveChatMessages({
    required String channelName,
    required List<ChatMessageEntry> messages,
    required List<String> activeUsers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/session/chat/save'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'channelName': channelName,
          'messages': messages.map((m) => m.toJson()).toList(),
          'activeUsers': activeUsers,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SaveSnapshotResponse.fromJson(jsonResponse);
      } else {
        return SaveSnapshotResponse(
          success: false,
          message: 'Failed to save chat: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SaveSnapshotResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Update session info
  static Future<bool> updateSessionInfo({
    required String channelName,
    required List<String> users,
    required String action,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/session/info/update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'channelName': channelName,
          'users': users,
          'action': action,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get session info
  static Future<GetSessionInfoResponse?> getSessionInfo({
    required String channelName,
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/session/info?channelName=$channelName&sessionId=$sessionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GetSessionInfoResponse.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get channel sessions
  static Future<List<String>> getChannelSessions({
    required String channelName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/session/channel/sessions?channelName=$channelName'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] as List;
        return data.map((s) => s.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

// Models
class SaveSnapshotResponse {
  final bool success;
  final String message;
  final String? filePath;
  final String? sessionId;

  SaveSnapshotResponse({
    required this.success,
    required this.message,
    this.filePath,
    this.sessionId,
  });

  factory SaveSnapshotResponse.fromJson(Map<String, dynamic> json) {
    return SaveSnapshotResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      filePath: json['data']?['filePath'],
      sessionId: json['data']?['sessionId'],
    );
  }
}

class ChatMessageEntry {
  final String userId;
  final String message;
  final DateTime timestamp;

  ChatMessageEntry({
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class GetSessionInfoResponse {
  final bool success;
  final String message;
  final SessionInfo? sessionInfo;
  final List<String> whiteboardImages;
  final List<String> chatFiles;

  GetSessionInfoResponse({
    required this.success,
    required this.message,
    this.sessionInfo,
    this.whiteboardImages = const [],
    this.chatFiles = const [],
  });

  factory GetSessionInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetSessionInfoResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      sessionInfo: json['data']?['sessionInfo'] != null
          ? SessionInfo.fromJson(json['data']['sessionInfo'])
          : null,
      whiteboardImages: (json['data']?['whiteboardImages'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      chatFiles: (json['data']?['chatFiles'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

class SessionInfo {
  final String sessionId;
  final String channelName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> users;
  final int whiteboardPagesCount;
  final int chatMessagesCount;

  SessionInfo({
    required this.sessionId,
    required this.channelName,
    required this.startTime,
    this.endTime,
    this.users = const [],
    this.whiteboardPagesCount = 0,
    this.chatMessagesCount = 0,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      sessionId: json['sessionId'] ?? '',
      channelName: json['channelName'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      users: (json['users'] as List?)?.map((u) => u.toString()).toList() ?? [],
      whiteboardPagesCount: json['whiteboardPagesCount'] ?? 0,
      chatMessagesCount: json['chatMessagesCount'] ?? 0,
    );
  }
}
