class ApiConfig {
  // Backend docker-compose maps container 8080 -> host 9080.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:9080',
  );

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse(baseUrl + normalized);
  }
}
