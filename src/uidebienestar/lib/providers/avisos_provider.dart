import 'package:flutter/material.dart';
import '../models/aviso.dart';

class AvisosProvider extends ChangeNotifier {
  final List<Aviso> _avisos = [];

  List<Aviso> get avisos => _avisos;

  List<Aviso> get avisosActivos =>
      _avisos.where((a) => a.activo).toList();

  void agregarAviso(Aviso aviso) {
    _avisos.insert(0, aviso);
    notifyListeners();
  }

  void editarAviso(int index, Aviso aviso) {
    _avisos[index] = aviso;
    notifyListeners();
  }

  void toggleActivo(int index) {
    _avisos[index] =
        _avisos[index].copyWith(activo: !_avisos[index].activo);
    notifyListeners();
  }
}
