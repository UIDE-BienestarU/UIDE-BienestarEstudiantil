// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _role;
  String? _userId;

  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  String? get userId => _userId;

  // Cargar datos guardados
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName');
    _email = prefs.getString('userEmail');
    _role = prefs.getString('userRole');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  // Limpiar al cerrar sesión
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    _name = null;
    _email = null;
    _role = null;
    _userId = null;
    notifyListeners();
  }
}