import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/uide_colors.dart';
import 'student_solicitud_enviada_screen.dart';

class StudentNuevaSolicitudScreen extends StatefulWidget {
  final String? tipoInicial;
  const StudentNuevaSolicitudScreen({super.key, this.tipoInicial});

  @override
  State<StudentNuevaSolicitudScreen> createState() =>
      _StudentNuevaSolicitudScreenState();
}

class _StudentNuevaSolicitudScreenState
    extends State<StudentNuevaSolicitudScreen> {
  final Map<String, List<String>> _tiposConSubtipos = {
    'Salud y bienestar físico': [
      'Atención médica general',
      'Emergencia médica / Primeros auxilios',
      'Validación de certificados médicos externos',
      'Atención odontológica (Clínica UIDE)',
      'Seguro de accidentes - Reembolso',
    ],
    'Apoyo psicológico y psicopedagógico': [
      'Asesoría psicológica individual',
      'Orientación vocacional y profesional',
      'Adaptaciones curriculares',
      'Intervención en crisis',
      'Talleres de prevención',
    ],
    'Becas y ayudas financieras': [
      'Beca por mérito académico',
      'Beca por situación socioeconómica',
      'Beca por mérito deportivo',
      'Beca por movilidad humana',
      'Beca por discapacidad',
      'Beca pueblos y nacionalidades',
      'Descuento por convenio institucional',
    ],
    'Gestión académica y administrativa': [
      'Solicitud de reingreso',
      'Cambio de carrera / sede',
      'Retiro temporal de asignatura',
      'Solicitud de tercera matrícula',
      'Justificación de faltas',
    ],
    'Deportes y cultura': [
      'Inscripción a clubes culturales',
      'Reserva de canchas / gimnasio',
      'Inscripción a selecciones deportivas',
      'Voluntariado universitario',
    ],
  };

  late String _tipoSeleccionado;
  late String _subtipoSeleccionado;
  final TextEditingController _descripcionController = TextEditingController();
  List<PlatformFile> _archivos = [];

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.tipoInicial ?? _tiposConSubtipos.keys.first;
    _subtipoSeleccionado = _tiposConSubtipos[_tipoSeleccionado]!.first;
  }

  bool _formularioValido() {
    return _descripcionController.text.trim().isNotEmpty;
  }

  Future<void> _seleccionarArchivos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _archivos.addAll(result.files));
    }
  }

  void _eliminarArchivo(int index) {
    setState(() => _archivos.removeAt(index));
  }

  void _mostrarErrorCampos() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Campos incompletos",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Por favor, completa los campos requeridos.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Aceptar",
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionEnvio() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Confirmar envío",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Revisa que la información y documentos sean correctos.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Regresar",
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIDEColors.conchevino,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _enviarSolicitud();
            },
            child: Text(
              "Confirmar",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _enviarSolicitud() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentSolicitudEnviadaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ AppBar hijo eliminado → se usa el AppBar del padre

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Tipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        isExpanded: true,
                        decoration: _inputDecoration(context),
                        items: _tiposConSubtipos.keys
                            .map((tipo) => DropdownMenuItem(
                                  value: tipo,
                                  child: Text(
                                    tipo,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _tipoSeleccionado = v!;
                            _subtipoSeleccionado =
                                _tiposConSubtipos[v]!.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _label("Subtipo de solicitud"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _subtipoSeleccionado,
                        isExpanded: true,
                        decoration: _inputDecoration(context),
                        items: _tiposConSubtipos[_tipoSeleccionado]!
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _subtipoSeleccionado = v!),
                      ),
                      const SizedBox(height: 24),
                      _label("Descripción"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descripcionController,
                        maxLines: 6,
                        style: GoogleFonts.poppins(fontSize: 15),
                        decoration: _inputDecoration(
                          context,
                          hint: "Describe el motivo de tu solicitud...",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIDEColors.conchevino,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (!_formularioValido()) {
                      _mostrarErrorCampos();
                      return;
                    }
                    _mostrarConfirmacionEnvio();
                  },
                  child: Text(
                    "Enviar solicitud",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: UIDEColors.conchevino),
      ),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }
}
