// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _role;

  String? get name => _name;
  String? get email => _email;
  String? get role => _role;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName');
    _email = prefs.getString('userEmail');
    _role = prefs.getString('userRole');
    notifyListeners();
  notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    _name = null;
    _email = null;
    _role = null;
    notifyListeners();
  }
}