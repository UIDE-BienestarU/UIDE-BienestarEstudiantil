import 'package:flutter/material.dart';
import '../models/solicitud.dart';
import '../services/solicitud_api_service.dart';

class AdminProvider extends ChangeNotifier {
  List<Solicitud> _todas = [];
  List<Solicitud> _filtradas = [];
  String _filtro = 'Todas';

  bool _cargando = false;
  String? _error;

  // ✅ cache TTL
  DateTime? _lastFetchAt;
  static const Duration _ttl = Duration(seconds: 45);

  // ✅ comportamiento pedido
  bool ocultarAprobadas = true; // “las aprobadas desaparecen”
  bool fifo = true; // FIFO: más antiguas primero

  List<Solicitud> get solicitudes => _filtradas;
  bool get cargando => _cargando;
  String? get error => _error;
  String get filtro => _filtro;

  bool get _cacheValida {
    final t = _lastFetchAt;
    if (t == null) return false;
    return DateTime.now().difference(t) < _ttl;
  }

  // =========================
  // Normalizadores de estado
  // =========================

  // UI -> API (lo que mandas al backend)
  // Ajusta aquí si tu API espera otra cosa.
  String _estadoUiToApi(String ui) {
    final e = ui.trim().toLowerCase();

    // soporta variantes
    if (e == 'por revisar' || e == 'pendiente') return 'por revisar';
    if (e == 'en progreso' || e == 'en revision' || e == 'en revisión')
      return 'en progreso';
    if (e == 'aprobada' || e == 'aprobado') return 'aprobada';

    // fallback: manda en minúsculas
    return e;
  }

  // API -> UI (lo que muestras y filtras con chips)
  String _estadoApiToUi(String api) {
    final e = api.trim().toLowerCase();

    if (e == 'pendiente') return 'Por revisar';
    if (e == 'por revisar') return 'Por revisar';
    if (e == 'en progreso') return 'En progreso';
    if (e == 'en revision' || e == 'en revisión') return 'En progreso';
    if (e == 'aprobada' || e == 'aprobado') return 'Aprobada';

    // Si vienen otros estados, capitaliza bonito
    if (e.isEmpty) return '';
    return e[0].toUpperCase() + e.substring(1);
  }

  // Fecha segura para FIFO
  DateTime _parseFechaSafe(String raw) {
    final r = raw.trim();
    final dt = DateTime.tryParse(r);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  // =========================
  // Cargar
  // =========================
  Future<void> cargarSolicitudes({bool force = false}) async {
    if (_cargando) return;

    if (!force && _cacheValida && _todas.isNotEmpty) {
      filtrar();
      notifyListeners();
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final pageResp =
          await SolicitudApiService.getSolicitudes(page: 1, limit: 100);

      // ✅ normaliza estados al entrar para que tus chips funcionen SIEMPRE
      _todas = pageResp.items
          .map((s) => s.copyWith(estado: _estadoApiToUi(s.estado)))
          .toList();

      _lastFetchAt = DateTime.now();
      filtrar();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (_error == null || _error!.isEmpty) _error = "Error de conexión";
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => cargarSolicitudes(force: true);

  void cambiarFiltro(String nuevo) {
    _filtro = nuevo;
    filtrar();
    notifyListeners();
  }

  void filtrar() {
    // base
    var list = List<Solicitud>.from(_todas);

    // ✅ ocultar aprobadas (desaparecen)
    if (ocultarAprobadas) {
      list = list
          .where((s) => s.estado.trim().toLowerCase() != 'aprobada')
          .toList();
    }

    // ✅ filtro por chip
    if (_filtro != 'Todas') {
      list = list.where((s) => s.estado == _filtro).toList();
    }

    // ✅ FIFO (más antiguas primero)
    if (fifo) {
      list.sort((a, b) =>
          _parseFechaSafe(a.fecha).compareTo(_parseFechaSafe(b.fecha)));
    }

    _filtradas = list;
  }

  // =========================
  // APROBAR (backend + remove)
  // =========================
  Future<void> aprobar(int id) async {
    // optimista: guarda copia por rollback
    final index = _todas.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final old = _todas[index];

    // ✅ si ocultarAprobadas=true, lo quitamos de una (desaparece)
    // si ocultarAprobadas=false, solo cambiamos el estado
    if (ocultarAprobadas) {
      _todas.removeAt(index);
    } else {
      _todas[index] = old.copyWith(estado: 'Aprobada');
    }

    filtrar();
    notifyListeners();

    try {
      // ✅ manda estado “válido” al API
      final apiEstado = _estadoUiToApi('Aprobada');

      final updated = await SolicitudApiService.updateEstadoSolicitud(
        solicitudId: id,
        estado: apiEstado, // <- aquí va normalizado (ej: "aprobada")
      );

      // si backend devuelve solicitud, actualizamos cache (si NO la ocultamos)
      if (!ocultarAprobadas && updated != null) {
        final fixed = updated.copyWith(estado: _estadoApiToUi(updated.estado));
        final idx2 = _todas.indexWhere((s) => s.id == id);
        if (idx2 != -1) _todas[idx2] = fixed;
      }

      _lastFetchAt = DateTime.now();
      filtrar();
      notifyListeners();
    } catch (e) {
      // rollback
      if (ocultarAprobadas) {
        _todas.insert(index, old);
      } else {
        final idx = _todas.indexWhere((s) => s.id == id);
        if (idx != -1) _todas[idx] = old;
      }

      filtrar();
      notifyListeners();
      rethrow;
    }
  }

  // compat
  void aprobarLocal(int id) {
    aprobar(id);
  }
}
