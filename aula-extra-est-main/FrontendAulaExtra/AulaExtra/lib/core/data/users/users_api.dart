import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:http/http.dart' as http;

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
    required String displayName,
    required String educationLevel,
    required String biography,
    required String mobileNumber,
    required String phoneNumber,
  }) async {
    final payload = <String, dynamic>{
      'displayName': displayName.trim().isEmpty ? null : displayName.trim(),
      'educationLevel': educationLevel.trim().isEmpty ? null : educationLevel.trim(),
      'biography': biography.trim().isEmpty ? null : biography.trim(),
      'mobileNumber': mobileNumber.trim().isEmpty ? null : mobileNumber.trim(),
      'phoneNumber': phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
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
      throw UsersException('Falha ao guardar perfil (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const UsersException('Resposta inválida do servidor');
    }

    return UserProfileDto.fromJson(obj);
  }
}

class UsersException implements Exception {
  const UsersException(this.message);
  final String message;

  @override
  String toString() => message;
}
