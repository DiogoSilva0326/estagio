import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/reservation_payment_result_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/reservation_payment_review_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_area_summary_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:http/http.dart' as http;

class ReservationsCalendarApi {
  Future<List<StudentCalendarItemDto>> getMyWeek({
    required String token,
    String? weekStart,
  }) async {
    final res = await http.get(
      ApiConfig.uri(
        weekStart == null || weekStart.trim().isEmpty
            ? '/api/Reservations/me/week'
            : '/api/Reservations/me/week?weekStart=$weekStart',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao carregar calendário (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(StudentCalendarItemDto.fromJson)
        .toList(growable: false);
  }

  Future<List<StudentCalendarItemDto>> getMyUpcoming({
    required String token,
    int limit = 4,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Reservations/me/upcoming?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao carregar próximas aulas (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(StudentCalendarItemDto.fromJson)
        .toList(growable: false);
  }

  Future<StudentAreaSummaryDto> getMyAreaSummary({
    required String token,
    required String areaId,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Reservations/me/area-summary?idArea=$areaId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao carregar resumo da área (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    return StudentAreaSummaryDto.fromJson(obj);
  }

  Future<List<ProfessorCalendarItemDto>> getProfessorWeek({
    required String token,
    String? weekStart,
  }) async {
    final res = await http.get(
      ApiConfig.uri(
        weekStart == null || weekStart.trim().isEmpty
            ? '/api/Reservations/professor/week'
            : '/api/Reservations/professor/week?weekStart=$weekStart',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorCalendarException(
        'Falha ao carregar calendário do professor (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ProfessorCalendarException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ProfessorCalendarItemDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ProfessorCalendarItemDto>> getProfessorUpcoming({
    required String token,
    int limit = 4,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Reservations/professor/upcoming?limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorCalendarException(
        'Falha ao carregar próximas aulas do professor (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) {
      throw const ProfessorCalendarException('Resposta inválida do servidor');
    }

    return obj
        .whereType<Map<String, dynamic>>()
        .map(ProfessorCalendarItemDto.fromJson)
        .toList(growable: false);
  }

  Future<void> acceptReservation({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Reservations/$reservationId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        _extractErrorMessage(
          res.body,
          'Falha ao aceitar aula (${res.statusCode})',
        ),
      );
    }
  }

  Future<ReservationPaymentReviewDto> getReservationPaymentReview({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Reservations/$reservationId/payment-review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const StudentCalendarException('A marcação já não está disponível.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        _extractErrorMessage(
          res.body,
          'Falha ao carregar pagamento da aula (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    return ReservationPaymentReviewDto.fromJson(obj);
  }

  Future<ReservationPaymentResultDto> payAndAcceptReservation({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Reservations/$reservationId/pay-and-accept'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        _extractErrorMessage(
          res.body,
          'Falha ao pagar e confirmar aula (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    return ReservationPaymentResultDto.fromJson(obj);
  }

  Future<void> rejectReservation({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Reservations/$reservationId/reject'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao recusar aula (${res.statusCode})',
      );
    }
  }

  Future<String?> getReservationStatus({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Reservations/$reservationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      return null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao validar aula (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    final status = obj['status']?.toString().trim();
    if (status == null || status.isEmpty) return null;
    return status;
  }

  Future<void> cancelReservation({
    required String token,
    required String reservationId,
  }) async {
    final getRes = await http.get(
      ApiConfig.uri('/api/Reservations/$reservationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (getRes.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (getRes.statusCode == 404) {
      throw const StudentCalendarException('A reserva já não existe.');
    }
    if (getRes.statusCode < 200 || getRes.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao obter reserva (${getRes.statusCode})',
      );
    }

    final obj = jsonDecode(getRes.body);
    if (obj is! Map<String, dynamic>) {
      throw const StudentCalendarException('Resposta inválida do servidor');
    }

    final payload = Map<String, dynamic>.from(obj)
      ..['idReservation'] =
          obj['idReservation'] ?? obj['IdReservation'] ?? reservationId
      ..['status'] = 'canceled';

    final putRes = await http.put(
      ApiConfig.uri('/api/Reservations/$reservationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (putRes.statusCode == 401) {
      throw const StudentCalendarException('Sessão expirada');
    }
    if (putRes.statusCode < 200 || putRes.statusCode >= 300) {
      throw StudentCalendarException(
        'Falha ao cancelar aula (${putRes.statusCode})',
      );
    }
  }

  Future<void> cancelReservationAsProfessor({
    required String token,
    required String reservationId,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Reservations/$reservationId/cancel-by-professor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorCalendarException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorCalendarException(
        _extractErrorMessage(
          res.body,
          'Falha ao cancelar aula (${res.statusCode})',
        ),
      );
    }
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
    // fallback below
  }

  return fallback;
}
