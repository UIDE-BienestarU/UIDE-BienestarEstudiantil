import 'dart:io';
import 'package:flutter/material.dart';

import '../models/objeto_perdido.dart';
import '../services/objetos_perdidos_service.dart';
import '../services/admin_objetos_perdidos_service.dart';
import '../utils/cache_box.dart';

class ObjetosPerdidosProvider extends ChangeNotifier {
  final _cache = CacheBox<List<ObjetoPerdido>>();

  bool loading = false;
  String? error;

  final Duration ttl;

  ObjetosPerdidosProvider({this.ttl = const Duration(minutes: 5)});

  List<ObjetoPerdido> get items => _cache.data ?? [];

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    error = e;
    notifyListeners();
  }

  Future<void> load({
    bool force = false,
    int page = 1,
    int limit = 20,
    String? estado,
  }) async {
    if (!force && _cache.hasData && _cache.isFresh(ttl)) return;
    if (loading) return;

    _setLoading(true);
    _setError(null);

    try {
      final pageResp = await ObjetosPerdidosService.getObjetos(
        page: page,
        limit: limit,
        estado: estado,
      );

      _cache.set(pageResp.items);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void invalidate() {
    _cache.clear();
    notifyListeners();
  }

  Future<void> adminReportar({
    required String titulo,
    required String descripcion,
    File? foto,
    String? lugarEncontrado,
    String estado = 'encontrado',
  }) async {
    if (loading) return;

    _setLoading(true);
    _setError(null);

    try {
      await AdminObjetosPerdidosService.reportar(
        titulo: titulo,
        descripcion: descripcion,
        foto: foto,
        lugarEncontrado: lugarEncontrado,
        estado: estado,
      );

      invalidate();
      await load(force: true, page: 1, limit: 50);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> adminCambiarEstado({
    required int id,
    required String estado,
  }) async {
    if (loading) return;

    _setLoading(true);
    _setError(null);

    try {
      await AdminObjetosPerdidosService.actualizarEstado(
        id: id,
        estado: estado,
      );

      final current = List<ObjetoPerdido>.from(items);
      final idx = current.indexWhere((x) => x.id == id);

      if (idx != -1) {
        current[idx] = current[idx].copyWith(estado: estado);
        _cache.set(current);
        notifyListeners();
      } else {
        invalidate();
        await load(force: true, page: 1, limit: 50);
      }
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> adminEliminar({required int id}) async {
    if (loading) return;

    _setLoading(true);
    _setError(null);

    try {
      await AdminObjetosPerdidosService.eliminar(id: id);

      final current = List<ObjetoPerdido>.from(items)
        ..removeWhere((x) => x.id == id);

      _cache.set(current);
      notifyListeners();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }
}
