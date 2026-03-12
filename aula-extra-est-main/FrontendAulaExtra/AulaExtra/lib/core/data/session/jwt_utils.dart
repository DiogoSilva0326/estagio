import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? tryDecodePayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final jsonStr = utf8.decode(base64Url.decode(normalized));
      final obj = json.decode(jsonStr);
      return obj is Map<String, dynamic> ? obj : null;
    } catch (_) {
      return null;
    }
  }

  static List<String> extractRoles(String jwt) {
    final payload = tryDecodePayload(jwt);
    if (payload == null) return const [];

    final rolesRaw = payload['roles'];
    if (rolesRaw is String && rolesRaw.trim().isNotEmpty) {
      return rolesRaw
          .split(',')
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList(growable: false);
    }

    // Fallback if backend ever sends single role claim.
    final roleRaw = payload['role'];
    if (roleRaw is String && roleRaw.trim().isNotEmpty) {
      return [roleRaw.trim()];
    }

    return const [];
  }
}
