// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // TU URL DE NGROK (mantenla mientras ngrok esté abierto)
  static const String _baseUrl = 'https://nonbilabiate-cursorily-brandee.ngrok-free.dev';

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('Intentando login...');
      print('URL: $_baseUrl/api/auth/login');
      print('Email: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo_institucional': email,
          'contrasena': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Respuesta del servidor: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        // CORREGIDO: tu backend devuelve "user", no "usuario"
        final user = body['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', body['token']);
        await prefs.setString('userId', user['id'].toString());
        await prefs.setString('userName', user['nombre_completo'] ?? 'Usuario');
        await prefs.setString('userEmail', user['correo_institucional']);
        await prefs.setString('userRole', user['rol']);

        return {
          'success': true,
          'role': user['rol'],
          'message': 'Login exitoso',
        };
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Error ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Tiempo agotado. El backend no responde.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Sin conexión. Revisa ngrok y el backend.',
      };
    } catch (e) {
      print('Error inesperado: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ====== Métodos auxiliares (todo bien) ======
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (_) {}
    }
    await prefs.clear();
  }
}