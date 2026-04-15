import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage_store_base.dart';

class SharedPreferencesTokenStore implements TokenStore {
  static const _tokenKey = 'auth.jwt';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

TokenStore createTokenStore() => SharedPreferencesTokenStore();
