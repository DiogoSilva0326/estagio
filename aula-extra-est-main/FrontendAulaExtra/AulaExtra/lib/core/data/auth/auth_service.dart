import 'package:aula_extra/core/data/auth/auth_api.dart';
import 'package:aula_extra/core/data/auth/dtos/auth_user_dto.dart';
import 'package:aula_extra/core/data/session/jwt_utils.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/session/preferences_service.dart';

class AuthService {
  AuthService({
    AuthApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? AuthApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  String? _nonEmpty(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  String? _deriveFullName(AuthUserDto? user) {
    final displayName = _nonEmpty(user?.displayName);
    if (displayName != null) return displayName;

    final firstName = _nonEmpty(user?.firstName) ?? '';
    final lastName = _nonEmpty(user?.lastName) ?? '';
    final combined = ('$firstName $lastName').trim();
    return combined.isNotEmpty ? combined : null;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.login(email: email, password: password);
    await _tokenStorage.saveToken(res.token);

    final roles = res.roles.isNotEmpty ? res.roles : JwtUtils.extractRoles(res.token);
    
    // ADICIONA ESTAS LINHAS:
    final savedRoleString = await PreferencesService.loadPreferredRole();
    Role? preferredRole;
    if (savedRoleString != null) {
      final clean = savedRoleString.toLowerCase().replaceAll('role.', '');
      preferredRole = Role.values.firstWhere((r) => r.name == clean, orElse: () => Role.none);
    }

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      // PASSA O preferredRole AQUI TAMBÉM
      appRole: mapBackendRolesToAppRole(roles, preferredRole: preferredRole),
      email: res.user?.email ?? email,
      username: res.user?.username,
      fullName: _deriveFullName(res.user),
    );
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    String? educationLevel,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final res = await _api.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      educationLevel: _nonEmpty(educationLevel),
    );

    await _tokenStorage.saveToken(res.token);
    final roles = res.roles.isNotEmpty ? res.roles : JwtUtils.extractRoles(res.token);

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      appRole: mapBackendRolesToAppRole(roles),
      email: res.user?.email ?? email,
      username: res.user?.username,
      fullName: _deriveFullName(res.user) ?? _nonEmpty(fullName) ?? fullName,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<AuthSession> refresh() async {
    final existingToken = await _tokenStorage.loadToken();
    if (existingToken == null || existingToken.trim().isEmpty) {
      throw const AuthException('Sessão expirada');
    }

    final res = await _api.refresh(token: existingToken);
    await _tokenStorage.saveToken(res.token);

    final roles = res.roles.isNotEmpty ? res.roles : JwtUtils.extractRoles(res.token);

    // 1. LEITURA ROBUSTA DA PREFERÊNCIA
    final savedRoleString = await PreferencesService.loadPreferredRole();
    Role? preferredRole;
    
    if (savedRoleString != null) {
      // Limpa a string de "Role.tutor" para "tutor"
      final clean = savedRoleString.toLowerCase().replaceAll('role.', '');
      // Procura no Enum o valor correspondente
      preferredRole = Role.values.firstWhere(
        (r) => r.name.toLowerCase() == clean, 
        orElse: () => Role.none
      );
    }

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      appRole: mapBackendRolesToAppRole(roles, preferredRole: preferredRole),
      email: res.user?.email,
      username: res.user?.username,
      fullName: _deriveFullName(res.user),
    );
  }

  static Role mapBackendRolesToAppRole(List<String> roles, {Role? preferredRole}) {
    final normalized = roles.map((r) => r.trim().toLowerCase()).toSet();

    // Verifica se o user é Professor/Admin no banco de dados
    final isActualTeacher = normalized.contains('professor') || 
                            normalized.contains('teacher') || 
                            normalized.contains('admin');

    // REGRA DE IMPERSONATION: Se for professor, ele pode ser o que quiser (para testes)
    if (isActualTeacher) {
      if (preferredRole != null && preferredRole != Role.none) {
        return preferredRole;
      }
      return Role.teacher; // Default se não houver preferência
    }

    // Se não for professor, segue a regra normal de permissões reais
    if (preferredRole == Role.student) return Role.student;
    
    // Fallback para utilizadores normais
    return Role.student;
  }


  static void applySessionToProvider(UserProvider user, AuthSession session) {
    user.setAccount(
      UserAccount(
        fullName: session.fullName,
        email: session.email,
        username: session.username,
      ),
    );
    user.setRole(session.appRole);
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.backendRoles,
    required this.appRole,
    this.email,
    this.username,
    this.fullName,
  });

  final String token;
  final List<String> backendRoles;
  final Role appRole;
  final String? email;
  final String? username;
  final String? fullName;
}
