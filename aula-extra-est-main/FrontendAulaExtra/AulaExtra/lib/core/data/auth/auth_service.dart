import 'package:aula_extra/core/data/auth/auth_api.dart';
import 'package:aula_extra/core/data/auth/dtos/auth_response_dto.dart';
import 'package:aula_extra/core/data/auth/dtos/auth_user_dto.dart';
import 'package:aula_extra/core/data/session/jwt_utils.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/session/preferences_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<Role?> _loadPreferredRole() async {
    final savedRoleString = await PreferencesService.loadPreferredRole();
    if (savedRoleString == null) return null;

    final clean = savedRoleString.toLowerCase().replaceAll('role.', '');
    return Role.values.firstWhere(
      (r) => r.name == clean,
      orElse: () => Role.none,
    );
  }

  GoogleSignIn _createGoogleSignInClient({String? clientId}) {
    final configuredClientId = (clientId ?? '').trim();

    if (configuredClientId.isNotEmpty) {
      return GoogleSignIn(
        scopes: const ['email', 'profile'],
        clientId: configuredClientId,
      );
    }

    return GoogleSignIn(scopes: const ['email', 'profile']);
  }

  String _configuredGoogleClientIdFromDefines() {
    final primary = const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '',
    ).trim();

    if (primary.isNotEmpty) return primary;

    final legacy = const String.fromEnvironment(
      'ID_CLIENT_GOOGLE',
      defaultValue: '',
    ).trim();
    return legacy;
  }

  Future<String?> _resolveGoogleClientId() async {
    final fromDefines = _configuredGoogleClientIdFromDefines();
    if (fromDefines.isNotEmpty) return fromDefines;

    try {
      return await _api.googleClientId();
    } catch (_) {
      return null;
    }
  }

  AuthSession _buildSessionFromResponse(
    AuthResponseDto res, {
    required String fallbackEmail,
    required Role? preferredRole,
    String? fallbackFullName,
  }) {
    final roles = res.roles.isNotEmpty ? res.roles : JwtUtils.extractRoles(res.token);

    return AuthSession(
      token: res.token,
      backendRoles: roles,
      appRole: mapBackendRolesToAppRole(roles, preferredRole: preferredRole),
      email: res.user?.email ?? fallbackEmail,
      username: res.user?.username,
      fullName: _deriveFullName(res.user) ?? fallbackFullName,
    );
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.login(email: email, password: password);
    await _tokenStorage.saveToken(res.token);
    final preferredRole = await _loadPreferredRole();
    return _buildSessionFromResponse(
      res,
      fallbackEmail: email,
      preferredRole: preferredRole,
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
    final preferredRole = await _loadPreferredRole();
    return _buildSessionFromResponse(
      res,
      fallbackEmail: email,
      preferredRole: preferredRole,
      fallbackFullName: _nonEmpty(fullName) ?? fullName,
    );
  }

  Future<AuthSession> loginWithGoogle() async {
    final configuredClientId = await _resolveGoogleClientId();
    final googleSignIn = _createGoogleSignInClient(clientId: configuredClientId);

    GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } catch (e) {
      if ((configuredClientId == null || configuredClientId.isEmpty)) {
        throw const AuthException(
          'Não foi possível iniciar o login com Google: falta configuração do Client ID no frontend e no backend.',
        );
      }
      throw AuthException('Não foi possível iniciar o login com Google: $e');
    }

    if (account == null) {
      throw const AuthException('Autenticação Google cancelada');
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.trim().isEmpty) {
      throw const AuthException('Não foi possível obter o token do Google');
    }

    final res = await _api.googleLogin(idToken: idToken);
    await _tokenStorage.saveToken(res.token);

    final preferredRole = await _loadPreferredRole();
    return _buildSessionFromResponse(
      res,
      fallbackEmail: account.email,
      preferredRole: preferredRole,
      fallbackFullName: account.displayName,
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

    final preferredRole = await _loadPreferredRole();
    return _buildSessionFromResponse(
      res,
      fallbackEmail: res.user?.email ?? '',
      preferredRole: preferredRole,
    );
  }

  static Role mapBackendRolesToAppRole(List<String> roles, {Role? preferredRole}) {
    final normalized = roles.map((r) => r.trim().toLowerCase()).toSet();

    bool hasRole(Role role) {
      switch (role) {
        case Role.teacher:
          return normalized.contains('professor') ||
              normalized.contains('teacher') ||
              normalized.contains('admin');
        case Role.tutor:
          return normalized.contains('tutor');
        case Role.psychologist:
          return normalized.contains('psicologo') ||
              normalized.contains('psychologist');
        case Role.student:
          return normalized.contains('aluno') ||
              normalized.contains('student') ||
              normalized.contains('standard');
        case Role.none:
          return false;
      }
    }

    if (preferredRole != null && preferredRole != Role.none && hasRole(preferredRole)) {
      return preferredRole;
    }

    if (hasRole(Role.teacher)) return Role.teacher;
    if (hasRole(Role.tutor)) return Role.tutor;
    if (hasRole(Role.psychologist)) return Role.psychologist;
    if (hasRole(Role.student)) return Role.student;
    return Role.none;
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
