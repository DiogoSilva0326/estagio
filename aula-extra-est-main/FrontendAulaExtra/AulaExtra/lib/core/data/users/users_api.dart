import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UsersApi {
  Future<UserProfileDto> getMe({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const UsersException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw UsersException('Falha ao carregar perfil (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const UsersException('Resposta inválida do servidor');
    }

    return UserProfileDto.fromJson(obj);
  }

  Future<UserProfileDto> updateMe({
    required String token,
    required String username,
    required String displayName,
    required String educationLevel,
    required String biography,
    required String mobileNumber,
    required String phoneNumber,
    required String website,
  }) async {
    final payload = <String, dynamic>{
      'username': username.trim().isEmpty ? null : username.trim(),
      'displayName': displayName.trim().isEmpty ? null : displayName.trim(),
      'educationLevel': educationLevel.trim().isEmpty
          ? null
          : educationLevel.trim(),
      'biography': biography.trim().isEmpty ? null : biography.trim(),
      'mobileNumber': mobileNumber.trim().isEmpty ? null : mobileNumber.trim(),
      'phoneNumber': phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
      'website': website.trim().isEmpty ? null : website.trim(),
    };

    final res = await http.put(
      ApiConfig.uri('/api/Users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 401) {
      throw const UsersException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw UsersException(
        _extractErrorMessage(
          res.body,
          'Falha ao guardar perfil (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const UsersException('Resposta inválida do servidor');
    }

    return UserProfileDto.fromJson(obj);
  }

  Future<UserProfileDto> uploadMyProfileImage({
    required String token,
    required List<int> bytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/api/Users/me/profile-image/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: _resolveImageMediaType(fileName),
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 401) {
      throw const UsersException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw UsersException(
        _extractErrorMessage(
          res.body,
          'Falha ao enviar imagem (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const UsersException('Resposta inválida do servidor');
    }

    return UserProfileDto.fromJson(obj);
  }

  Future<UserProfileDto> setMyProfileImageFromUrl({
    required String token,
    required String imageUrl,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Users/me/profile-image/from-url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageUrl': imageUrl.trim()}),
    );

    if (res.statusCode == 401) {
      throw const UsersException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw UsersException(
        _extractErrorMessage(
          res.body,
          'Falha ao definir avatar (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const UsersException('Resposta inválida do servidor');
    }

    return UserProfileDto.fromJson(obj);
  }

  Future<void> deleteMyProfileImage({required String token}) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Users/me/profile-image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const UsersException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw UsersException(
        _extractErrorMessage(
          res.body,
          'Falha ao remover imagem (${res.statusCode})',
        ),
      );
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error.trim();
        }
      }
    } catch (_) {
      // Fall back to the default message below.
    }
    return fallback;
  }

  MediaType _resolveImageMediaType(String fileName) {
    final normalized = fileName.trim().toLowerCase();

    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (normalized.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (normalized.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (normalized.endsWith('.svg')) {
      return MediaType('image', 'svg+xml');
    }
    if (normalized.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }

    return MediaType('image', 'png');
  }
}

class UsersException implements Exception {
  const UsersException(this.message);
  final String message;

  @override
  String toString() => message;
}
