import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/pending_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/submitted_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/student_professor_evaluations_api.dart';

class StudentProfessorEvaluationsService {
  StudentProfessorEvaluationsService({
    StudentProfessorEvaluationsApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? StudentProfessorEvaluationsApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final StudentProfessorEvaluationsApi _api;
  final TokenStorage _tokenStorage;

  Future<List<SubmittedProfessorEvaluationDto>> getSubmitted() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }

    return _api.getSubmitted(token: token);
  }

  Future<List<PendingProfessorEvaluationDto>> getPending() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }

    return _api.getPending(token: token);
  }

  Future<void> submit({
    required String professorId,
    required int rating,
    String? comments,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const StudentProfessorEvaluationsException('Sessão expirada');
    }

    final trimmed = comments?.trim();
    final normalized = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    return _api.submit(
      token: token,
      professorId: professorId,
      rating: rating,
      comments: normalized,
    );
  }
}
