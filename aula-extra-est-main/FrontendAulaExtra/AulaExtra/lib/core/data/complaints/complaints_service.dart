import 'package:aula_extra/core/data/complaints/complaints_api.dart';
import 'package:aula_extra/core/data/complaints/dtos/related_user_complaint_request_dto.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ComplaintsService {
  ComplaintsService({
    ComplaintsApi? api,
    TokenStorage? tokenStorage,
  }) : _api = api ?? ComplaintsApi(),
       _tokenStorage = tokenStorage ?? TokenStorage();

  final ComplaintsApi _api;
  final TokenStorage _tokenStorage;

  Future<void> createRelatedUserComplaint(
    RelatedUserComplaintRequestDto request,
  ) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ComplaintsException('Sessão expirada');
    }

    await _api.createRelatedUserComplaint(token: token, request: request);
  }
}