import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/auth/dtos/auth_response_dto.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Authentication/Login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 401) {
      throw const AuthException('Credenciais inválidas');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw AuthException('Falha no login (${res.statusCode})');
    }

    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(obj);
  }

  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? educationLevel,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': '$firstName $lastName'.trim(),
    };

    if (educationLevel != null && educationLevel.trim().isNotEmpty) {
      payload['educationLevel'] = educationLevel.trim();
    }

    final res = await http.post(
      ApiConfig.uri('/api/Authentication/Register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 409) {
      throw const AuthException('Email já existe');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw AuthException('Falha no registo (${res.statusCode})');
    }

    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(obj);
  }

  Future<AuthResponseDto> refresh({
    required String token,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Authentication/Refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const AuthException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw AuthException('Falha ao atualizar sessão (${res.statusCode})');
    }

    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(obj);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
