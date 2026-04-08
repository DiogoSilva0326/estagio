import 'package:aula_extra/core/data/lesson_classroom/dtos/lesson_classroom_entry_dto.dart';
import 'package:aula_extra/core/data/lesson_classroom/lesson_classroom_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class LessonClassroomService {
  LessonClassroomService({LessonClassroomApi? api, TokenStorage? tokenStorage})
    : _api = api ?? LessonClassroomApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final LessonClassroomApi _api;
  final TokenStorage _tokenStorage;

  Future<LessonClassroomEntryDto> enterClassroom({
    required String reservationId,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const LessonClassroomException(
        'Sessão expirada. Faça login novamente.',
      );
    }

    return _api.enterClassroom(token: token, reservationId: reservationId);
  }
}
