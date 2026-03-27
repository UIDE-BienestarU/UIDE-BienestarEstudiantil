import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  String get nombreCompleto =>
      (_user?['nombre_completo'] ?? _user?['nombre'] ?? 'Estudiante')
          .toString();

  String get correo =>
      (_user?['correo_institucional'] ?? _user?['correo'] ?? '').toString();

  String get rol => (_user?['rol'] ?? '').toString();

  int? get id {
    final v = _user?['id'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  void setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
