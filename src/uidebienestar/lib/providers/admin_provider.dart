import 'package:flutter/material.dart';
import '../models/solicitud.dart';
import '../services/solicitud_api_service.dart';

class AdminProvider extends ChangeNotifier {
  List<Solicitud> _todas = [];
  List<Solicitud> _filtradas = [];
  String _filtro = 'Todas';
  bool _cargando = true;
  String? _error;

  List<Solicitud> get solicitudes => _filtradas;
  bool get cargando => _cargando;
  String? get error => _error;
  String get filtro => _filtro;

  AdminProvider() {
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _todas = await SolicitudApiService.getSolicitudes();
      filtrar();
    } catch (e) {
      _error = "Error de conexión";
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void cambiarFiltro(String nuevo) {
    _filtro = nuevo;
    filtrar();
    notifyListeners();
  }

  void filtrar() {
    if (_filtro == 'Todas') {
      _filtradas = _todas;
    } else {
      _filtradas = _todas.where((s) => s.estado == _filtro).toList();
    }
  }

  void aprobar(String id) {
    final index = _todas.indexWhere((s) => s.id == id);
    if (index != -1) {
      _todas[index] = Solicitud(
        id: _todas[index].id,
        estudiante: _todas[index].estudiante,
        correo: _todas[index].correo,
        tipo: _todas[index].tipo,
        fecha: _todas[index].fecha,
        estado: 'Aprobada',
      );
      filtrar();
      notifyListeners();
    }
  }
}