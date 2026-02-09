import 'package:flutter/material.dart';
import '../models/notificacion.dart';
import '../services/notificaciones_service.dart';

class NotificacionesProvider extends ChangeNotifier {
  final List<Notificacion> _items = [];
  bool _loading = false;
  String? _error;

  List<Notificacion> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool unread = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await NotificacionesService.fetch(page: 1, limit: 30, unread: unread);
      _items
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    // optimista: marca en UI y luego confirma en API
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    final old = _items[idx];
    if (old.leido) return;

    _items[idx] = Notificacion(
      id: old.id,
      titulo: old.titulo,
      mensaje: old.mensaje,
      leido: true,
      fechaEnvio: old.fechaEnvio,
      data: old.data,
    );
    notifyListeners();

    try {
      await NotificacionesService.markAsRead(id);
    } catch (_) {
      // rollback si falla
      _items[idx] = old;
      notifyListeners();
      rethrow;
    }
  }
}
