import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/uide_colors.dart';
import 'student_nueva_solicitud.dart';

class StudentHistorialScreen extends StatefulWidget {
  const StudentHistorialScreen({super.key});

  @override
  State<StudentHistorialScreen> createState() => _StudentHistorialScreenState();
}

class _StudentHistorialScreenState extends State<StudentHistorialScreen> {
  int? _solicitudExpandida;
  String _estadoSeleccionado = 'Todas';

  final List<Map<String, dynamic>> _todasLasSolicitudes = [
    {
      "tipo": "Apoyo Económico",
      "fecha": "24 Oct 2023",
      "estado": "Pendiente",
      "numero": "RQ-1024",
    },
    {
      "tipo": "Servicio de Comedor",
      "fecha": "10 Oct 2023",
      "estado": "En Progreso",
      "numero": "RQ-0850",
    },
    {
      "tipo": "Taller de Liderazgo",
      "fecha": "15 Oct 2023",
      "estado": "Aprobada",
      "numero": "RQ-0988",
    },
  ];

  @override
  void initState() {
    super.initState();
    _ordenarPorFecha();
  }

  void _ordenarPorFecha() {
    final format = DateFormat('dd MMM yyyy', 'en_US');
    _todasLasSolicitudes.sort((a, b) {
      return format.parse(b['fecha']).compareTo(format.parse(a['fecha']));
    });
  }

  List<Map<String, dynamic>> get _solicitudesFiltradas {
    return _todasLasSolicitudes.where((s) {
      if (_estadoSeleccionado == 'Todas') return true;
      return s['estado'] ==
          (_estadoSeleccionado == 'Pendientes'
              ? 'Pendiente'
              : 'Aprobada');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,

      // ✅ ÚNICA APPBAR
      appBar: AppBar(
        title: Text(
          "Mis Solicitudes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ================= FILTROS =================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _filtrosEstado(),
          ),

          // ================= CONTENIDO + EMPTY STATE =================
          Expanded(
            child: Column(
              children: [
                // LISTA
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount: _solicitudesFiltradas.length,
                    itemBuilder: (context, index) {
                      return _cardSolicitud(
                        _solicitudesFiltradas[index],
                        index,
                      );
                    },
                  ),
                ),

                // EMPTY STATE SIEMPRE VISIBLE
                Expanded(
                  flex: 2,
                  child: _emptyState(),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: UIDEColors.conchevino,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentNuevaSolicitudScreen(),
            ),
          );
        },
      ),
    );
  }

  // ================= FILTROS =================
  Widget _filtrosEstado() {
    final estados = ['Todas', 'Pendientes', 'Aprobadas'];

    return Row(
      children: estados.map((e) {
        final activo = _estadoSeleccionado == e;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilterChip(
            label: Text(e),
            selected: activo,
            selectedColor: UIDEColors.conchevino,
            backgroundColor: Colors.white,
            showCheckmark: false,
            labelStyle: GoogleFonts.poppins(
              color: activo ? Colors.white : UIDEColors.conchevino,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() => _estadoSeleccionado = e);
            },
          ),
        );
      }).toList(),
    );
  }

  // ================= CARD SOLICITUD =================
  Widget _cardSolicitud(Map<String, dynamic> s, int index) {
    final expandida = _solicitudExpandida == index;
    final estado = s['estado'];

    Color colorEstado = estado == "Pendiente"
        ? UIDEColors.amarillo
        : estado == "En Progreso"
            ? UIDEColors.azul
            : Colors.green.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _solicitudExpandida = expandida ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${s['numero']} ${s['tipo']}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['fecha'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estado.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorEstado,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    expandida
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ================= CRONOLOGÍA =================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expandida
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _timelineEstado(estado),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ================= TIMELINE =================
  Widget _timelineEstado(String estadoActual) {
    final pasos = ['Pendiente', 'En Progreso', 'Aprobada'];
    final indexActual = pasos.indexOf(estadoActual);

    Color colorPaso(int i) {
      if (i > indexActual) return Colors.grey.shade300;
      if (pasos[i] == 'Pendiente') return UIDEColors.amarillo;
      if (pasos[i] == 'En Progreso') return UIDEColors.azul;
      return Colors.green.shade700;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 24, 16),
      child: Column(
        children: pasos.asMap().entries.map((e) {
          final i = e.key;
          final texto = e.value;
          final activo = i <= indexActual;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 22,
                    color: activo ? colorPaso(i) : Colors.grey.shade300,
                  ),
                  if (i < pasos.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: activo ? colorPaso(i) : Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  texto,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                        activo ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            size: 70,
            color: UIDEColors.conchevino.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            "¡Sigue adelante!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: UIDEColors.conchevino,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cada solicitud es un paso más\nhacia tu éxito académico.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
