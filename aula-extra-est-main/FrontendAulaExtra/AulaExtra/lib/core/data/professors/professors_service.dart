import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_evaluations_overview_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_language_dto.dart';
import 'package:aula_extra/core/data/professors/professors_api.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_stats_dto.dart';
import 'package:aula_extra/core/data/session/jwt_utils.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ProfessorsService {
  ProfessorsService({ProfessorsApi? api, TokenStorage? tokenStorage})
    : _api = api ?? ProfessorsApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ProfessorsApi _api;
  final TokenStorage _tokenStorage;

  Future<AuthSession> upsertMyProfessor({
    required String username,
    required String mobileNumber,
    required String nif,
    String? currentSchool,
    int? yearsExperience,
    String? presentationVideoUrl,
    String? photo,
    String? biography,
    String? vat,
    String? iban,
    String? ibanDocumentUrl,
    List<UpsertProfessorCertificateInput>? certificates,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    final res = await _api.upsertMe(
      token: existingToken,
      username: username.trim(),
      mobileNumber: mobileNumber.trim(),
      nif: nif.trim(),
      currentSchool: currentSchool,
      yearsExperience: yearsExperience,
      presentationVideoUrl: presentationVideoUrl,
      photo: photo,
      biography: biography,
      vat: vat,
      iban: iban,
      ibanDocumentUrl: ibanDocumentUrl,
      certificates: certificates,
    );

    await _tokenStorage.saveToken(res.token);
    final roles = res.roles.isNotEmpty
        ? res.roles
        : JwtUtils.extractRoles(res.token);

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      appRole: AuthService.mapBackendRolesToAppRole(roles),
      email: res.user?.email,
      username: res.user?.username,
      fullName: _deriveFullName(res.user),
    );
  }

  Future<List<ProfessorAlunoDto>> fetchMeusAlunos({String? role}) async {
    final token = await _tokenStorage.loadToken(); 
    if (token == null) throw Exception('No token');

    return _api.getMeusAlunos(token: token, role: role); 
  }

  Future<ProfessorProfileDto?> getMyProfessor() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMe(token: existingToken);
  }

  Future<PublicProfessorProfileDto> getPublicProfessorProfile({
    required String idProfessor,
  }) {
    return _api.getPublicProfessorProfile(idProfessor: idProfessor);
  }

  Future<List<DisciplinaDto>> getMyDisciplinas() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMyDisciplinas(token: existingToken);
  }

  Future<List<DisciplinaDto>> setMyDisciplinas({
    required List<String> ids,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.setMyDisciplinas(token: existingToken, ids: ids);
  }

  Future<List<DisciplinaDto>> createMyDisciplina({
    String? idDisciplina,
    required String idArea,
    String? idCicloEstudo,
    required String nome,
    String? descricao,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.createMyDisciplina(
      token: existingToken,
      idDisciplina: idDisciplina,
      idArea: idArea,
      idCicloEstudo: idCicloEstudo,
      nome: nome,
      descricao: descricao,
    );
  }

  Future<List<DisciplinaDto>> updateMyDisciplina({
    required String currentIdDisciplina,
    String? idDisciplina,
    required String idArea,
    String? idCicloEstudo,
    required String nome,
    String? descricao,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.updateMyDisciplina(
      token: existingToken,
      currentIdDisciplina: currentIdDisciplina,
      idDisciplina: idDisciplina,
      idArea: idArea,
      idCicloEstudo: idCicloEstudo,
      nome: nome,
      descricao: descricao,
    );
  }

  Future<List<DisciplinaDto>> removeMyDisciplina({
    required String idDisciplina,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.removeMyDisciplina(
      token: existingToken,
      idDisciplina: idDisciplina,
    );
  }

  Future<List<ProfessorLanguageDto>> getLanguagesCatalog() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getLanguagesCatalog(token: existingToken);
  }

  Future<List<ProfessorLanguageDto>> getMyLanguages() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMyLanguages(token: existingToken);
  }

  Future<List<ProfessorLanguageDto>> setMyLanguages({
    required List<ProfessorLanguageDto> items,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.setMyLanguages(
      token: existingToken,
      items: items
          .where((item) => item.idLanguage.trim().isNotEmpty)
          .map(
            (item) => UpsertProfessorLanguageInput(
              idLanguage: item.idLanguage,
              proficiencyLevel: item.proficiencyLevel,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<ProfessorStatsDto> getMyStats() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMyStats(token: existingToken);
  }

  Future<GlobalProfessorRatingSummaryDto> getGlobalRatingSummary() {
    return _api.getGlobalRatingSummary();
  }

  Future<ProfessorEvaluationsOverviewDto> getMyEvaluations() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMyEvaluations(token: existingToken);
  }

  Future<List<ProfessorCertificateDto>> getMyCertificates() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.getMyCertificates(token: existingToken);
  }

  Future<ProfessorCertificateDto> createMyCertificate({
    required String name,
    String? description,
    required List<int> bytes,
    required String fileName,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.createMyCertificate(
      token: existingToken,
      name: name,
      description: description,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<ProfessorCertificateDto> updateMyCertificate({
    required String idCertificate,
    required String name,
    String? description,
    String? fileUrl,
    List<int>? bytes,
    String? fileName,
  }) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    return _api.updateMyCertificate(
      token: existingToken,
      idCertificate: idCertificate,
      name: name,
      description: description,
      fileUrl: fileUrl,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<void> deleteMyCertificate(String idCertificate) async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const ProfessorsException('Sessão expirada');
    }

    await _api.deleteMyCertificate(
      token: existingToken,
      idCertificate: idCertificate,
    );
  }

  String? _deriveFullName(dynamic user) {
    // user is AuthUserDto but keep minimal coupling
    final displayName = (user?.displayName as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final firstName = (user?.firstName as String?)?.trim() ?? '';
    final lastName = (user?.lastName as String?)?.trim() ?? '';
    final combined = ('$firstName $lastName').trim();
    return combined.isNotEmpty ? combined : null;
  }
}
