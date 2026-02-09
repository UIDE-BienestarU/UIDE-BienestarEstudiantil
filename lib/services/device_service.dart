import 'package:dio/dio.dart';
import 'api_client.dart';

class DeviceService {
  // Probamos variantes de mount típicas.
  // ✅ Si tu backend es app.use('/api/device', router) => /device/register
  // ✅ Si tu backend es app.use('/api/devices', router) => /devices/register
  // ✅ Si tu backend es app.use('/api', router) y router tiene /device/register => /device/register
  static const List<String> _baseCandidates = [
    '/device',
    '/devices',
    '', // último intento: /register directo (raro, pero a veces pasa)
  ];

  static Future<void> register({
    required String fcmToken,
    required String platform, // 'android' | 'ios'
    String? deviceId,
  }) async {
    final body = <String, dynamic>{
      'fcmToken': fcmToken,
      'platform': platform,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    };

    await _tryPost('/register', body);
  }

  static Future<void> unregister({
    required String fcmToken,
  }) async {
    final body = <String, dynamic>{'fcmToken': fcmToken};
    await _tryPost('/unregister', body);
  }

  static Future<void> _tryPost(String path, Map<String, dynamic> body) async {
    DioException? last;

    for (final base in _baseCandidates) {
      final url = '$base$path';

      try {
        await ApiClient.dio.post(url, data: body);
        return; // ✅ éxito
      } on DioException catch (e) {
        last = e;

        final status = e.response?.statusCode;

        // 404 => probamos el siguiente candidato
        if (status == 404) continue;

        // 401 => tu ApiClient debería refrescar y reintentar.
        // Si igual cae aquí, devolvemos mensaje claro.
        final data = e.response?.data;
        final msg = (data is Map ? (data['message'] ?? data['error']) : null) ??
            'Error registrando dispositivo';

        throw Exception(msg.toString());
      }
    }

    // Si todos fueron 404
    final tried = _baseCandidates.map((b) => '$b$path').join(', ');
    final status = last?.response?.statusCode;
    throw Exception(
      'Ruta de device no encontrada (status: ${status ?? "?"}). Probé: $tried',
    );
  }
}
