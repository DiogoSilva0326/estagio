import 'dart:convert';

import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class ContactsApi {
  Future<List<ContactUserSummaryDto>> getMyContacts({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Communication/contacts/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ContactsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactsException(
        'Falha ao carregar contactos (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ContactsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ContactUserSummaryDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ContactUserSummaryDto>> addContactByUsername({
    required String token,
    required String username,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Communication/contacts/by-username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'username': username}),
    );

    if (res.statusCode == 401) {
      throw const ContactsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const ContactsException('Utilizador não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactsException(
        'Falha ao adicionar contacto (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ContactsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ContactUserSummaryDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ContactUserSummaryDto>> addContactByUserId({
    required String token,
    required String userId,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Communication/contacts/by-user-id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (res.statusCode == 401) {
      throw const ContactsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const ContactsException('Utilizador não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactsException(
        'Falha ao adicionar contacto (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ContactsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ContactUserSummaryDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ContactUserSummaryDto>> acceptInviteByUsername({
    required String token,
    required String username,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Communication/contacts/by-username/$username/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ContactsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const ContactsException('Utilizador não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactsException('Falha ao aceitar convite (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ContactsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ContactUserSummaryDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ContactUserSummaryDto>> rejectInviteByUsername({
    required String token,
    required String username,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Communication/contacts/by-username/$username/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ContactsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const ContactsException('Utilizador não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactsException('Falha ao rejeitar convite (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ContactsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ContactUserSummaryDto.fromJson)
        .toList(growable: false);
  }
}

class ContactsException implements Exception {
  const ContactsException(this.message);
  final String message;

  @override
  String toString() => message;
}
