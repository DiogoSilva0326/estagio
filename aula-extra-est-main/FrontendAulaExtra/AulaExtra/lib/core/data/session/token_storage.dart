import 'token_storage_store_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage_store_shared_prefs.dart'
    if (dart.library.html) 'token_storage_store_web.dart';

class TokenStorage {
  final TokenStore _store = createTokenStore();

  Future<void> saveToken(String token) async {
    await _store.saveToken(token);
  }

  Future<String?> loadToken() async {
    return _store.loadToken();
  }

  Future<void> clearToken() async {
    await _store.clearToken();
  }

  Future<void> savePreferredRole(String roleName) async {
    final prefs = await SharedPreferences.getInstance(); // ou a tua store atual
    await prefs.setString('preferred_role', roleName);
  }

  // Ler a role escolhida (para quando a app arranca ou faz F5)
  Future<String?> loadPreferredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_role');
  }

  // Limpar a role quando o utilizador faz logout
  Future<void> clearPreferredRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('preferred_role');
  }
}
