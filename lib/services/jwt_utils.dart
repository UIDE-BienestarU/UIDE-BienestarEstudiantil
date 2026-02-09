import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded);

      return (map is Map<String, dynamic>) ? map : null;
    } catch (_) {
      return null;
    }
  }

  static String? getRole(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    // tu backend usa "rol"
    final r = payload['rol'] ?? payload['role'];
    return r?.toString();
  }
}
