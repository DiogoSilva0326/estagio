import 'dart:convert';

import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ChatFilesApi {
  Future<ChatUploadedFileDto> uploadFile({
    required String token,
    required List<int> bytes,
    required String fileName,
    String? contentType,
    String? userId,
    String? roomId,
  }) async {
    final query = <String, String>{
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      if (roomId != null && roomId.trim().isNotEmpty) 'roomId': roomId.trim(),
    };

    final uri = _buildUri('/api/files/upload', queryParameters: query.isEmpty ? null : query);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    final mediaType = _tryParseMediaType(contentType);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: mediaType,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401) {
      throw const ChatFilesException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatFilesException(_extractErrorMessage(response.body, response.statusCode));
    }

    final obj = jsonDecode(response.body);
    if (obj is! Map<String, dynamic>) {
      throw const ChatFilesException('Resposta inválida do servidor');
    }

    return ChatUploadedFileDto.fromJson(obj);
  }

  Future<List<ChatFileInfoDto>> getUserFiles({
    required String token,
    required String username,
    int limit = 100,
  }) async {
    final uri = _buildUri('/api/files/user/$username', queryParameters: <String, String>{'limit': '$limit'});

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _parseFilesResponse(response);
  }

  Future<List<ChatFileInfoDto>> getRoomFiles({
    required String token,
    required String roomId,
    String? username,
    int limit = 100,
  }) async {
    final uri = _buildUri(
      '/api/files/room/$roomId',
      queryParameters: <String, String>{
        'limit': '$limit',
        if (username != null && username.trim().isNotEmpty) 'username': username.trim(),
      },
    );

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _parseFilesResponse(response);
  }

  Future<void> deleteFile({
    required String token,
    required String fileId,
  }) async {
    final uri = _buildUri('/api/files/$fileId');

    final response = await http.delete(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw const ChatFilesException('Sessão expirada');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatFilesException(_extractErrorMessage(response.body, response.statusCode));
    }
  }

  List<ChatFileInfoDto> _parseFilesResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const ChatFilesException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatFilesException(_extractErrorMessage(response.body, response.statusCode));
    }

    final obj = jsonDecode(response.body);
    if (obj is! Map<String, dynamic>) {
      throw const ChatFilesException('Resposta inválida do servidor');
    }

    final rawFiles = obj['files'];
    if (rawFiles is! List) {
      throw const ChatFilesException('Lista de ficheiros inválida');
    }

    return rawFiles
        .whereType<Map>()
        .map((item) => ChatFileInfoDto.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final obj = jsonDecode(body);
      if (obj is Map && obj['message'] != null) {
        return obj['message'].toString();
      }
    } catch (_) {}

    return 'Falha ao processar ficheiro ($statusCode)';
  }

  MediaType? _tryParseMediaType(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty || !normalized.contains('/')) {
      return null;
    }

    try {
      return MediaType.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final base = RealtimeChatConfig.hubBaseUrl();
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath').replace(queryParameters: queryParameters);
  }
}

class ChatFilesException implements Exception {
  const ChatFilesException(this.message);

  final String message;

  @override
  String toString() => message;
}
