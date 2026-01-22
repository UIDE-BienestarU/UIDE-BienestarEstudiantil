import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';

class StudentHistorialScreen extends StatefulWidget {
  const StudentHistorialScreen({Key? key}) : super(key: key);

  @override
  State<StudentHistorialScreen> createState() =>
      _StudentHistorialScreenState();
}

class _StudentHistorialScreenState extends State<StudentHistorialScreen> {
  String _estadoSeleccionado = 'Todos';
  String _busqueda = '';

  final List<Map<String, dynamic>> _todasLasSolicitudes = const [
    {
      "tipo": "Beca Académica",
      "fecha": "15 Nov 2025",
      "estado": "Pendiente",
    },
    {
      "tipo": "Cita Psicológica",
      "fecha": "10 Nov 2025",
      "estado": "Aprobada",
    },
    {
      "tipo": "Certificado",
      "fecha": "05 Nov 2025",
      "estado": "En revisión",
    },
    {
      "tipo": "Seguro Médico",
      "fecha": "01 Nov 2025",
      "estado": "Aprobada",
    },
  ];

  List<Map<String, dynamic>> get _solicitudesFiltradas {
    return _todasLasSolicitudes.where((s) {
      final coincideEstado =
          _estadoSeleccionado == 'Todos' ||
          s['estado'] == _estadoSeleccionado;

      final coincideTexto = s['tipo']
          .toString()
          .toLowerCase()
          .contains(_busqueda.toLowerCase());

      return coincideEstado && coincideTexto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _barraBusqueda(),
        _filtrosEstado(),

        Expanded(
          child: _solicitudesFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    "No hay solicitudes",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _solicitudesFiltradas.length,
                  itemBuilder: (context, index) {
                    final solicitud = _solicitudesFiltradas[index];
                    return _cardSolicitud(solicitud);
                  },
                ),
        ),
      ],
    );
  }

  // ================= UI COMPONENTS =================

  Widget _barraBusqueda() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _busqueda = value),
        decoration: InputDecoration(
          hintText: "Buscar solicitud...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filtrosEstado() {
    final estados = ['Todos', 'Pendiente', 'En revisión', 'Aprobada'];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: estados.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final estado = estados[index];
          final seleccionado = _estadoSeleccionado == estado;

          return ChoiceChip(
            label: Text(estado),
            selected: seleccionado,
            selectedColor: UIDEColors.conchevino,
            labelStyle: TextStyle(
              color: seleccionado ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() => _estadoSeleccionado = estado);
            },
          );
        },
      ),
    );
  }

  Widget _cardSolicitud(Map<String, dynamic> solicitud) {
    final estado = solicitud["estado"];

    Color estadoColor;
    IconData icono;

    switch (estado) {
      case 'Pendiente':
        estadoColor = Colors.orange;
        icono = Icons.hourglass_top;
        break;
      case 'En revisión':
        estadoColor = Colors.blue;
        icono = Icons.autorenew;
        break;
      default:
        estadoColor = Colors.green;
        icono = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICONO
          CircleAvatar(
            radius: 24,
            backgroundColor: estadoColor.withOpacity(0.15),
            child: Icon(icono, color: estadoColor),
          ),

          const SizedBox(width: 14),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solicitud["tipo"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Enviada: ${solicitud["fecha"]}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ESTADO
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: estadoColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              estado,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
