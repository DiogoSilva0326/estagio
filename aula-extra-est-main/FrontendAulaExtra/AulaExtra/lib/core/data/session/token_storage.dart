import 'token_storage_store_base.dart';
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
}
