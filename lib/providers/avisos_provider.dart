import 'dart:io';

import 'package:flutter/material.dart';
import '../models/aviso.dart';
import '../models/comentario.dart';
import '../services/publicaciones_service.dart';
import '../services/comentarios_service.dart';

// ✅ imports admin
import '../services/admin_publicaciones_service.dart';
import '../services/admin_objetos_perdidos_service.dart';

class AvisosProvider extends ChangeNotifier {
  final List<Aviso> _avisos = [];
  bool _loading = false;
  String? _error;

  List<Aviso> get avisos => List.unmodifiable(_avisos);
  bool get loading => _loading;
  String? get error => _error;

  List<Aviso> get avisosActivos => _avisos.where((a) => a.activo).toList();

  List<Aviso> avisosPorCategoria(CategoriaAviso categoria) {
    return _avisos.where((a) => a.activo && a.categoria == categoria).toList();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // ======================
  // API: cargar publicaciones (ESTUDIANTE)
  // Estudiante usa el GET normal.
  // Si el backend filtra activo/inactivo, lo maneja el backend.
  // ======================
  Future<void> loadPublicaciones({int page = 1, int limit = 20}) async {
    if (_loading) return;

    _setLoading(true);
    _setError(null);

    try {
      final items = await PublicacionesService.fetchPublicaciones(
        page: page,
        limit: limit,
      );

      _avisos
        ..clear()
        ..addAll(items);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  // ======================
  // ✅ ADMIN: refresh (normalmente usa más limit)
  // ======================
  Future<void> adminRefresh() => loadPublicaciones(page: 1, limit: 100);

  // ======================
  // ✅ ADMIN: crear publicación (backend + refresh)
  // Nota: AdminPublicacionesService debe aceptar imagenFile
  // ======================
  Future<void> adminCrearPublicacion({
    required String titulo,
    required String contenido,
    File? imagen,
  }) async {
    await AdminPublicacionesService.crear(
      titulo: titulo,
      contenido: contenido,
      imagenFile: imagen,
    );

    // ✅ refresca lista para que se vea inmediatamente en admin
    await adminRefresh();
  }

  // =========================================================
  // ✅ PUBLICAR SEGÚN CATEGORÍA (backend real, no “local only”)
  // =========================================================
  Future<void> adminCrearSegunCategoria({
    required CategoriaAviso categoria,
    required String titulo,
    required String contenido,
    File? imagen,
  }) async {
    if (categoria == CategoriaAviso.comunicado) {
      await AdminPublicacionesService.crear(
        titulo: titulo,
        contenido: contenido,
        imagenFile: imagen,
      );

      // ✅ para que al estudiante le aparezca sin “quedarse pegado”
      await loadPublicaciones(page: 1, limit: 20);
      return;
    }

    // ✅ objeto perdido va por su endpoint real
    await AdminObjetosPerdidosService.reportar(
      titulo: titulo,
      descripcion: contenido,
      foto: imagen, // misma File seleccionada
      estado: 'encontrado',
    );

    // OJO: no tocamos _avisos aquí porque NO es publicación.
    // El estudiante lo verá en ObjetosPerdidosService.getObjetos()
  }

  // ======================
  // REST: crear comentario
  // ======================
  Future<void> crearComentario(String objetoId, String texto) async {
    await ComentariosService.crear(objetoId: objetoId, mensaje: texto);
  }

  // ======================
  // SOCKET: inyectar comentario en tiempo real
  // ======================
  void pushComentarioFromSocket(String avisoId, Comentario c) {
    final idx = _avisos.indexWhere((a) => a.id == avisoId);
    if (idx == -1) return;

    final aviso = _avisos[idx];

    // evita duplicados si llega repetido
    final exists = aviso.comentarios.any((x) => x.id == c.id);
    if (exists) return;

    _avisos[idx] = aviso.copyWith(
      comentarios: [...aviso.comentarios, c],
    );
    notifyListeners();
  }

  // ======================
  // Helpers locales (UI / pruebas)
  // ======================
  void agregarAviso(Aviso aviso) {
    _avisos.insert(0, aviso);
    notifyListeners();
  }

  void editarAviso(String id, Aviso avisoActualizado) {
    final index = _avisos.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _avisos[index] = avisoActualizado;
    notifyListeners();
  }

  void eliminarAviso(String id) {
    _avisos.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleActivo(String id) {
    final index = _avisos.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final aviso = _avisos[index];
    _avisos[index] = aviso.copyWith(activo: !aviso.activo);
    notifyListeners();
  }

  void agregarComentario(String avisoId, String texto) {
    final index = _avisos.indexWhere((a) => a.id == avisoId);
    if (index == -1) return;

    final aviso = _avisos[index];
    _avisos[index] = aviso.copyWith(
      comentarios: [
        ...aviso.comentarios,
        Comentario(
          texto: texto,
          fecha: DateTime.now(),
          autorNombre: "Juan Fuentes",
          autorIniciales: "JF",
        )
      ],
    );

    notifyListeners();
  }

  Aviso avisoPorId(String id) {
    return _avisos.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception("Aviso no encontrado"),
    );
  }

  void limpiarTodo() {
    _avisos.clear();
    notifyListeners();
  }

  void eliminarComentario(String avisoId, String comentarioId) {
    final index = _avisos.indexWhere((a) => a.id == avisoId);
    if (index == -1) return;

    final aviso = _avisos[index];
    _avisos[index] = aviso.copyWith(
      comentarios:
          aviso.comentarios.where((c) => c.id != comentarioId).toList(),
    );

    notifyListeners();
  }
}
