import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for communicating with the Synget.AgoraIntegrator.API backend
class AgoraIntegratorService {
  AgoraIntegratorService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Get the base URL from environment variable
  String get _baseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing env var: API_BASE_URL');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// Fetch RTC token for video/audio calls
  Future<TokenResponse> fetchRtcToken({
    required String channelName,
    required String uid,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/token/rtc'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'uid': uid,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('RTC token request failed', response.statusCode, response.body);
    }

    return TokenResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Fetch RTM token for messaging
  Future<TokenResponse> fetchRtmToken({
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/token/rtm'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('RTM token request failed', response.statusCode, response.body);
    }

    return TokenResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Create a new session
  Future<SessionResponse> createSession({
    required String channelName,
    required String hostUserId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/session/create'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'hostUserId': hostUserId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Create session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Join an existing session
  Future<SessionResponse> joinSession({
    required String channelName,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/session/join'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'userId': userId,
      }),
    );

    if (response.statusCode == 404) {
      throw SessionNotFoundException(channelName);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Join session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Leave a session
  Future<SessionResponse> leaveSession({
    required String channelName,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/session/leave'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'userId': userId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Leave session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Get session information
  Future<SessionResponse?> getSession(String channelName) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/session/$channelName'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Get all sessions
  Future<List<SessionResponse>> getAllSessions() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/session'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get all sessions failed', response.statusCode, response.body);
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => SessionResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// End a session
  Future<void> endSession(String channelName) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/session/$channelName'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('End session failed', response.statusCode, response.body);
    }
  }
}

/// Token response from the API
class TokenResponse {
  TokenResponse({
    required this.token,
    this.channelName,
    this.uid,
    required this.tokenType,
  });

  final String token;
  final String? channelName;
  final String? uid;
  final String tokenType;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'] as String,
      channelName: json['channelName'] as String?,
      uid: json['uid'] as String?,
      tokenType: json['tokenType'] as String,
    );
  }
}

/// Session response from the API
class SessionResponse {
  SessionResponse({
    required this.channelName,
    this.hostUserId,
    this.token,
    this.createdAt,
    required this.users,
    this.message,
  });

  final String channelName;
  final String? hostUserId;
  final String? token;
  final DateTime? createdAt;
  final List<SessionUser> users;
  final String? message;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      channelName: json['channelName'] as String,
      hostUserId: json['hostUserId'] as String?,
      token: json['token'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => SessionUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }
}

/// Represents a user in a session
class SessionUser {
  SessionUser({
    required this.userId,
    required this.isAudioMuted,
    required this.isVideoMuted,
    this.joinedAt,
  });

  final String userId;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final DateTime? joinedAt;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      userId: json['userId'] as String,
      isAudioMuted: json['isAudioMuted'] as bool? ?? false,
      isVideoMuted: json['isVideoMuted'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt'] as String) : null,
    );
  }
}

/// Set user audio mute state
Future<SessionResponse> setUserAudioMute({
  required String channelName,
  required String userId,
  required bool muted,
}) async {
  final response = await _client.post(
    Uri.parse('$_baseUrl/api/session/$channelName/mute/audio'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'muted': muted}),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException('Set user audio mute failed', response.statusCode, response.body);
  }

  return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<SessionResponse> setUserVideoMute({
  required String channelName,
  required String userId,
  required bool muted,
}) async {
  final response = await _client.post(
    Uri.parse('$_baseUrl/api/session/$channelName/mute/video'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'muted': muted}),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException('Set user video mute failed', response.statusCode, response.body);
  }

  return SessionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<SessionUser?> getSessionUser({
  required String channelName,
  required String userId,
}) async {
  final response = await _client.get(
    Uri.parse('$_baseUrl/api/session/$channelName/user/$userId'),
    headers: const {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 404) return null;
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException('Get session user failed', response.statusCode, response.body);
  }

  return SessionUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

/// API Exception
class ApiException implements Exception {
  ApiException(this.message, this.statusCode, this.body);

  final String message;
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException: $message (status: $statusCode) - $body';
}

/// Session not found exception
class SessionNotFoundException implements Exception {
  SessionNotFoundException(this.channelName);

  final String channelName;

  @override
  String toString() => 'Session "$channelName" not found';
}
