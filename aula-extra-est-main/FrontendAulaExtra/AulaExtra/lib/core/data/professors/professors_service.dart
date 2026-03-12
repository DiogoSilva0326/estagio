import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/professors/professors_api.dart';
import 'package:aula_extra/core/data/session/jwt_utils.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ProfessorsService {
  ProfessorsService({
    ProfessorsApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? ProfessorsApi(),
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
    final roles = res.roles.isNotEmpty ? res.roles : JwtUtils.extractRoles(res.token);

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      appRole: AuthService.mapBackendRolesToAppRole(roles),
      email: res.user?.email,
      username: res.user?.username,
      fullName: _deriveFullName(res.user),
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
