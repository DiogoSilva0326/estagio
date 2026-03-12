import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/pending_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/submitted_evaluation_dto.dart';
import 'package:http/http.dart' as http;

class StudentEvaluationsApi {
  Future<List<SubmittedEvaluationDto>> getSubmitted({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/StudentEvaluations/submitted'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentEvaluationsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentEvaluationsException('Falha ao carregar avaliações (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentEvaluationsException('Resposta inválida do servidor');
    }

    return obj.whereType<Map<String, dynamic>>().map(SubmittedEvaluationDto.fromJson).toList(growable: false);
  }

  Future<List<PendingEvaluationDto>> getPending({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/StudentEvaluations/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentEvaluationsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentEvaluationsException('Falha ao carregar pendentes (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentEvaluationsException('Resposta inválida do servidor');
    }

    return obj.whereType<Map<String, dynamic>>().map(PendingEvaluationDto.fromJson).toList(growable: false);
  }

  Future<void> submit({
    required String token,
    required String lessonId,
    required int rating,
    required String? comments,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/StudentEvaluations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lessonId': lessonId,
        'rating': rating,
        'comments': comments,
      }),
    );

    if (res.statusCode == 401) {
      throw const StudentEvaluationsException('Sessão expirada');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      // backend usually returns { error: "..." }
      try {
        final obj = jsonDecode(res.body);
        final msg = (obj is Map && obj['error'] != null) ? obj['error'].toString() : null;
        throw StudentEvaluationsException(msg ?? 'Falha ao enviar avaliação (${res.statusCode})');
      } catch (_) {
        throw StudentEvaluationsException('Falha ao enviar avaliação (${res.statusCode})');
      }
    }
  }
}

class StudentEvaluationsException implements Exception {
  const StudentEvaluationsException(this.message);
  final String message;

  @override
  String toString() => message;
}
