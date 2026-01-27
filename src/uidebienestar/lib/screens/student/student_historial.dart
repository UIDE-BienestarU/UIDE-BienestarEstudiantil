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
          fillColor: Theme.of(context).inputDecorationTheme.fillColor
    ?? Theme.of(context).cardColor,

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
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,

              labelStyle: TextStyle(
                color: seleccionado
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium!.color,
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
    final Color estadoBase = UIDEColors.conchevino;
    final IconData icono = Icons.assignment_turned_in;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICONO ÚNICO Y PROFESIONAL
          CircleAvatar(
            radius: 24,
            backgroundColor: estadoBase.withOpacity(0.15),
            child: Icon(
              icono,
              color: estadoBase,
            ),
          ),


          const SizedBox(width: 14),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solicitud["tipo"],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 4),
                Text(
                  "Enviada: ${solicitud["fecha"]}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),


              ],
            ),
          ),

          // ESTADO (COLOR ÚNICO)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: estadoBase.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              solicitud["estado"],
              style: TextStyle(
                color: estadoBase.withOpacity(0.85),
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
