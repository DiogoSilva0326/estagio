import 'dart:convert';

import 'package:aula_extra/core/data/complaints/dtos/related_user_complaint_request_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class ComplaintsApi {
  Future<void> createRelatedUserComplaint({
    required String token,
    required RelatedUserComplaintRequestDto request,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Complaints/me/related-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 401) {
      throw const ComplaintsException('Sessão expirada');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ComplaintsException(
        _extractErrorMessage(
          res.body,
          'Não foi possível submeter a reclamação.',
        ),
      );
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['error'] ?? decoded['message'];
        final normalized = message?.toString().trim() ?? '';
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    } catch (_) {}

    return fallback;
  }
}

class ComplaintsException implements Exception {
  const ComplaintsException(this.message);

  final String message;

  @override
  String toString() => message;
}