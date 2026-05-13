class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:9080',
  );

  static Uri uri(String path) {
    final baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return baseUri.resolve(normalized);
  }

  static String? resolveUrl(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final absolute = Uri.tryParse(normalized);
    if (absolute != null && absolute.hasScheme) {
      return absolute.toString();
    }

    return uri(normalized.startsWith('/') ? normalized : '/$normalized').toString();
  }
}