import 'package:flutter/material.dart';
import '../models/aviso.dart';
import '../models/comentario.dart';

class AvisosProvider extends ChangeNotifier {
  final List<Aviso> _avisos = [];

  List<Aviso> get avisos => List.unmodifiable(_avisos);

  List<Aviso> get avisosActivos =>
      _avisos.where((a) => a.activo).toList();

  List<Aviso> avisosPorCategoria(CategoriaAviso categoria) {
    return _avisos
        .where((a) => a.activo && a.categoria == categoria)
        .toList();
  }


  // CRUD AVISOS (ADMIN)
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

  // COMENTARIOS (ESTUDIANTE)
  // SOLO OBJETOS PERDIDOS
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
        ),
      ],
    );

    notifyListeners();
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
      comentarios: aviso.comentarios
          .where((c) => c.id != comentarioId)
          .toList(),
    );

    notifyListeners();
  }

}
