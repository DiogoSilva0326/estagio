import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';

class AvailableRoles {
  AvailableRoles._();

  static Set<Role> fromBackendRoles(List<String> backendRoles) {
    final normalized = backendRoles
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    final available = <Role>{};

    if (normalized.contains('aluno') ||
        normalized.contains('student') ||
        normalized.contains('standard')) {
      available.add(Role.student);
    }

    if (normalized.contains('professor') ||
        normalized.contains('teacher') ||
        normalized.contains('admin')) {
      available.add(Role.teacher);
    }

    if (normalized.contains('tutor')) {
      available.add(Role.tutor);
    }

    if (normalized.contains('psicologo') || normalized.contains('psychologist')) {
      available.add(Role.psychologist);
    }

    return available;
  }

  static Future<Set<Role>> fetch() async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      return {Role.none};
    }

    final session = await AuthService(tokenStorage: tokenStorage).refresh();
    final available = fromBackendRoles(session.backendRoles);

    return available.isEmpty ? {Role.none} : available;
  }
}
