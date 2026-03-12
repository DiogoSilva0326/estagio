import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/pending_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/submitted_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/student_evaluations_api.dart';

class StudentEvaluationsService {
  StudentEvaluationsService({
    StudentEvaluationsApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? StudentEvaluationsApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final StudentEvaluationsApi _api;
  final TokenStorage _tokenStorage;

  Future<List<SubmittedEvaluationDto>> getSubmitted() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentEvaluationsException('Sessão expirada');
    }

    return _api.getSubmitted(token: token);
  }

  Future<List<PendingEvaluationDto>> getPending() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentEvaluationsException('Sessão expirada');
    }

    return _api.getPending(token: token);
  }

  Future<void> submit({
    required String lessonId,
    required int rating,
    String? comments,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentEvaluationsException('Sessão expirada');
    }

    final trimmed = comments?.trim();
    final normalized = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    return _api.submit(
      token: token,
      lessonId: lessonId,
      rating: rating,
      comments: normalized,
    );
  }
}
