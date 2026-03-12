import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class EducationService {
  EducationService({
    EducationApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? EducationApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final EducationApi _api;
  final TokenStorage _tokenStorage;

  Future<List<CicloEstudoDto>> getCiclosEstudo() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.getCiclosEstudo(token: token);
  }

  Future<List<AreaDto>> getAreas() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.getAreas(token: token);
  }

  Future<List<DisciplinaDto>> getDisciplinasByArea({required String idArea}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.getDisciplinasByArea(token: token, idArea: idArea);
  }

  Future<List<DisciplinaDto>> getCatalog() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.getCatalog(token: token);
  }

  Future<List<DisciplinaDto>> getMyDisciplinas() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.getMyDisciplinas(token: token);
  }

  Future<List<DisciplinaDto>> setMyDisciplinas({required List<String> ids}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.setMyDisciplinas(token: token, ids: ids);
  }

  Future<List<DisciplinaDto>> removeMyDisciplina({required String idDisciplina}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.removeMyDisciplina(token: token, idDisciplina: idDisciplina);
  }

  Future<List<DisciplinaDto>> removeMyArea({required String idArea}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const EducationException('Sessão expirada');
    }
    return _api.removeMyArea(token: token, idArea: idArea);
  }
}
