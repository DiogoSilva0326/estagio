import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TokenService {
  TokenService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Get the base URL from environment variable
  String get _baseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.trim().isEmpty) {
      // Fallback to legacy TOKEN_SERVER_URL if API_BASE_URL not set
      final legacyUrl = dotenv.env['TOKEN_SERVER_URL'];
      if (legacyUrl != null && legacyUrl.trim().isNotEmpty) {
        // Extract base URL from legacy token server URL
        final uri = Uri.parse(legacyUrl);
        return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
      }
      throw StateError('Missing env var: API_BASE_URL');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  Uri _requiredUri(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing env var: $key');
    }
    return Uri.parse(value);
  }

  /// Fetch RTC token using the new AgoraIntegrator API
  Future<String> fetchRtcToken({required int uid, required String channelName}) async {
    try {
      // Try the new API first
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/token/rtc'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid.toString(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final token = decoded['token'];
        if (token is String && token.isNotEmpty) {
          return token;
        }
      }
      throw StateError('RTC token request failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      // Fallback to legacy endpoint if new API fails
      return _fetchRtcTokenLegacy(uid: uid, channelName: channelName);
    }
  }

  /// Legacy method for backward compatibility
  Future<String> _fetchRtcTokenLegacy({required int uid, required String channelName}) async {
    final url = _requiredUri('TOKEN_SERVER_URL');

    final response = await _client.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'channelName': channelName,
        'role': 1,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('RTC token request failed: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw StateError('RTC token missing in response');
    }

    return token;
  }

  Future<WhiteboardToken> fetchWhiteboardToken({required int uid, required String channelName}) async {
    final url = _requiredUri('WHITEBOARD_TOKEN_URL');

    final response = await _client.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'channelName': channelName,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Whiteboard token request failed: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final uuid = decoded['uuid'];
    final token = decoded['token'];

    if (uuid is! String || uuid.isEmpty) {
      throw StateError('Whiteboard uuid missing in response');
    }
    if (token is! String || token.isEmpty) {
      throw StateError('Whiteboard token missing in response');
    }

    return WhiteboardToken(uuid: uuid, roomToken: token);
  }
}

class WhiteboardToken {
  const WhiteboardToken({required this.uuid, required this.roomToken});

  final String uuid;
  final String roomToken;
}
