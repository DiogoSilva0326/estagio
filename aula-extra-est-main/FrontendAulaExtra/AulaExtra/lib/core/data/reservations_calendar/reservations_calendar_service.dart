import 'package:aula_extra/core/data/reservations_calendar/dtos/student_area_summary_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/professor_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ReservationsCalendarService {
  ReservationsCalendarService({
    ReservationsCalendarApi? api,
    TokenStorage? tokenStorage,
  }) : _api = api ?? ReservationsCalendarApi(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final ReservationsCalendarApi _api;
  final TokenStorage _tokenStorage;

  Future<List<StudentCalendarItemDto>> getMyWeek({String? weekStart}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    return _api.getMyWeek(token: token, weekStart: weekStart);
  }

  Future<List<StudentCalendarItemDto>> getMyUpcoming({int limit = 4}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    return _api.getMyUpcoming(token: token, limit: limit);
  }

  Future<StudentAreaSummaryDto> getMyAreaSummary({
    required String areaId,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    return _api.getMyAreaSummary(token: token, areaId: areaId);
  }

  Future<List<ProfessorCalendarItemDto>> getProfessorWeek({
    String? weekStart,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorCalendarException('Sessão expirada');
    }

    return _api.getProfessorWeek(token: token, weekStart: weekStart);
  }

  Future<List<ProfessorCalendarItemDto>> getProfessorUpcoming({
    int limit = 4,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorCalendarException('Sessão expirada');
    }

    return _api.getProfessorUpcoming(token: token, limit: limit);
  }

  Future<void> acceptReservation({required String reservationId}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    await _api.acceptReservation(token: token, reservationId: reservationId);
  }

  Future<void> rejectReservation({required String reservationId}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    await _api.rejectReservation(token: token, reservationId: reservationId);
  }

  Future<String?> getReservationStatus({required String reservationId}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    return _api.getReservationStatus(
      token: token,
      reservationId: reservationId,
    );
  }

  Future<void> cancelReservation({required String reservationId}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentCalendarException('Sessão expirada');
    }

    await _api.cancelReservation(token: token, reservationId: reservationId);
  }
}
