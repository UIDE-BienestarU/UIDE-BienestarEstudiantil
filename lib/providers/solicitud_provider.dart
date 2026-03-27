import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../services/api_client.dart';
import '../services/documentos_service.dart';
import '../services/upload_service.dart';

// ✅ Para listar solicitudes
import '../models/solicitud.dart';
import '../services/solicitud_api_service.dart';

class SolicitudProvider extends ChangeNotifier {
  // =======================
  // Estado general
  // =======================
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? v) {
    _error = v;
    notifyListeners();
  }

  // =======================
  // ✅ CACHE de solicitudes (historial)
  // =======================
  final Duration _ttl = const Duration(minutes: 5);

  DateTime? _lastFetch;
  final List<Solicitud> _items = [];

  // paginación (si la usas)
  int _page = 1;
  int _limit = 20;
  int _total = 0;

  List<Solicitud> get items => List.unmodifiable(_items);
  int get page => _page;
  int get limit => _limit;
  int get total => _total;

  bool get hasCache => _items.isNotEmpty;
  bool get cacheFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _ttl;

  bool get canLoadMore {
    if (_total == 0) return true; // si backend no manda total, permitimos
    return _items.length < _total;
  }

  /// ✅ Limpia cache (útil cuando creas una solicitud nueva)
  void invalidateSolicitudesCache() {
    _items.clear();
    _lastFetch = null;
    _page = 1;
    _total = 0;
    notifyListeners();
  }

  /// ✅ Carga solicitudes con cache
  /// - reset=true: limpia y vuelve a cargar página 1
  /// - force=true: ignora cache
  Future<void> loadSolicitudes({
    bool reset = true,
    bool force = false,
    int limit = 20,
  }) async {
    if (_loading) return;

    // Si no es reset, queremos cargar más (paginación)
    final loadingMore = !reset;

    // ✅ si reset, y hay cache fresco, y no force => no llamamos al backend
    if (reset && !force && hasCache && cacheFresh) {
      return;
    }

    _limit = limit;

    _setError(null);
    _setLoading(true);

    try {
      if (reset) {
        _page = 1;
        _items.clear();
        _total = 0;
      }

      final resp = await SolicitudApiService.getSolicitudes(
        page: _page,
        limit: _limit,
      );

      // ✅ Evita duplicados si el backend repite o si recargas raro
      final existingIds = _items.map((e) => e.id).toSet();
      final nuevos = resp.items.where((s) => !existingIds.contains(s.id));

      _items.addAll(nuevos);

      _total = resp.total;
      _page = resp.page + 1;
      _lastFetch = DateTime.now();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          e.message ??
          'Error al cargar solicitudes';
      _setError(msg.toString());
      rethrow;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Pull-to-refresh directo
  Future<void> refreshSolicitudes({int limit = 20}) async {
    await loadSolicitudes(reset: true, force: true, limit: limit);
  }

  /// =======================
  /// Crear solicitud (flujo real 3 pasos)
  /// =======================
  Future<void> crearSolicitud({
    required Map<String, dynamic> payload,
    required List<File> archivos,
  }) async {
    if (_loading) return; // ✅ evita doble tap / doble request

    _setLoading(true);
    _setError(null);

    try {
      // ✅ Idempotency-Key: útil si tu backend lo respeta
      final key =
          "sol-${DateTime.now().millisecondsSinceEpoch}-${payload['subtipo_id'] ?? 'x'}";

      // 1) Crear solicitud
      final res = await ApiClient.dio.post(
        '/solicitudes-crear',
        data: payload,
        options: Options(headers: {'Idempotency-Key': key}),
      );

      final body = res.data;
      final data = (body is Map) ? (body['data'] ?? body) : body;

      final rawId = (data is Map)
          ? (data['id'] ?? data['solicitudId'] ?? data['solicitud_id'])
          : null;

      if (rawId == null) {
        throw Exception('No se recibió ID de solicitud');
      }

      final solicitudId = int.tryParse(rawId.toString()) ?? 0;
      if (solicitudId <= 0) {
        throw Exception('ID de solicitud inválido');
      }

      // 2) Subir archivos (si hay)
      final docs = <DocumentoPayload>[];

      if (archivos.isNotEmpty) {
        for (final f in archivos) {
          final up = await UploadService.uploadDocumento(f);
          final name = f.path.split(Platform.pathSeparator).last;

          docs.add(
            DocumentoPayload(
              urlArchivo: up.url,
              nombreDocumento: name,
              obligatorio: true,
            ),
          );
        }
      }

      // 3) Registrar documentos (si hay)
      if (docs.isNotEmpty) {
        await DocumentosService.addDocumentos(
          solicitudId: solicitudId,
          documentos: docs,
        );
      }

      // ✅ CLAVE: como ya cambió el backend state (creaste una),
      // invalidamos cache para que el historial se actualice
      invalidateSolicitudesCache();

      // (Opcional) podrías recargar aquí mismo:
      // await loadSolicitudes(reset: true, force: true);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          e.message ??
          'Error al crear solicitud';
      _setError(msg.toString());
      rethrow;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
