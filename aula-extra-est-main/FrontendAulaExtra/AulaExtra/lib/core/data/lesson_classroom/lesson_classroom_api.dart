import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/lesson_classroom/dtos/lesson_classroom_entry_dto.dart';
import 'package:http/http.dart' as http;

class LessonClassroomApi {
  LessonClassroomApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LessonClassroomEntryDto> enterClassroom({
    required String token,
    required String reservationId,
  }) async {
    final response = await _client.post(
      ApiConfig.uri('/api/Reservations/$reservationId/classroom-entry'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LessonClassroomException(_extractMessage(response));
    }

    return LessonClassroomEntryDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  String _extractMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}

    return 'Não foi possível preparar a entrada na aula.';
  }
}
