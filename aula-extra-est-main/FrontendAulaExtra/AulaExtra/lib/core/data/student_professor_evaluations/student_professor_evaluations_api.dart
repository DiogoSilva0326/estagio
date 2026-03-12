import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/pending_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/submitted_professor_evaluation_dto.dart';
import 'package:http/http.dart' as http;

class StudentProfessorEvaluationsApi {
  Future<List<SubmittedProfessorEvaluationDto>> getSubmitted({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/StudentProfessorEvaluations/submitted'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentProfessorEvaluationsException('Falha ao carregar avaliações (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentProfessorEvaluationsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(SubmittedProfessorEvaluationDto.fromJson)
        .toList(growable: false);
  }

  Future<List<PendingProfessorEvaluationDto>> getPending({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/StudentProfessorEvaluations/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentProfessorEvaluationsException('Falha ao carregar pendentes (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentProfessorEvaluationsException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(PendingProfessorEvaluationDto.fromJson)
        .toList(growable: false);
  }

  Future<void> submit({
    required String token,
    required String professorId,
    required int rating,
    required String? comments,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/StudentProfessorEvaluations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'professorId': professorId,
        'rating': rating,
        'comments': comments,
      }),
    );

    if (res.statusCode == 401) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final obj = jsonDecode(res.body);
        final msg = (obj is Map && obj['error'] != null) ? obj['error'].toString() : null;
        throw StudentProfessorEvaluationsException(msg ?? 'Falha ao enviar avaliação (${res.statusCode})');
      } catch (_) {
        throw StudentProfessorEvaluationsException('Falha ao enviar avaliação (${res.statusCode})');
      }
    }
  }
}

class StudentProfessorEvaluationsException implements Exception {
  const StudentProfessorEvaluationsException(this.message);
  final String message;

  @override
  String toString() => message;
}
