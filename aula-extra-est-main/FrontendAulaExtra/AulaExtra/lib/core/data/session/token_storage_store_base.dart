abstract class TokenStore {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}
