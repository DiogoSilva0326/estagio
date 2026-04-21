import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ads_form_data_dto.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ProfessorAdsService {
  ProfessorAdsService({ProfessorAdsApi? api, TokenStorage? tokenStorage})
    : _api = api ?? ProfessorAdsApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ProfessorAdsApi _api;
  final TokenStorage _tokenStorage;

  Future<List<ProfessorAdDto>> getProfessorAdsForProfessor({
    required String professorId,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorAdsException('Sessão expirada');
    }

    return _api.getProfessorAds(token: token, professorId: professorId);
  }

  Future<ProfessorAdsFormDataDto> getMyData() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorAdsException('Sessão expirada');
    }

    return _api.getMyData(token: token);
  }

  Future<ProfessorAdDto> upsertMyAd({
    required String idDisciplina,
    required String idTutoringType,
    required double sessionPrice,
    String? description,
    String? photoUrl,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorAdsException('Sessão expirada');
    }

    return _api.upsertMyAd(
      token: token,
      idDisciplina: idDisciplina,
      idTutoringType: idTutoringType,
      sessionPrice: sessionPrice,
      description: description,
      photoUrl: photoUrl,
    );
  }

  Future<ProfessorAdDto> updateMyAdStatus({
    required String idProfessorAd,
    required String status,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ProfessorAdsException('Sessão expirada');
    }

    return _api.updateMyAdStatus(
      token: token,
      idProfessorAd: idProfessorAd,
      status: status,
    );
  }
}
