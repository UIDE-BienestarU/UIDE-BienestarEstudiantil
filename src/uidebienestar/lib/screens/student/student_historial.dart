import 'package:flutter/material.dart';
import '../../theme/uide_colors.dart';

class StudentHistorialScreen extends StatefulWidget {
  const StudentHistorialScreen({Key? key}) : super(key: key);

  @override
  State<StudentHistorialScreen> createState() =>
      _StudentHistorialScreenState();
}

class _StudentHistorialScreenState extends State<StudentHistorialScreen> {
  int? _solicitudExpandida;

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
                    return _cardSolicitud(solicitud, index);
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

  Widget _cardSolicitud(Map<String, dynamic> solicitud, int index) {
  final bool expandida = _solicitudExpandida == index;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      UIDEColors.conchevino.withOpacity(0.15),
                  child: const Icon(
                    Icons.assignment,
                    color: UIDEColors.conchevino,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitud["tipo"],
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Enviada: ${solicitud["fecha"]}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                Icon(
                  expandida
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        // 🔥 TIMELINE DESPLEGABLE
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: expandida
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _timelineEstado(solicitud["estado"]),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    ),
  );
}
Widget _timelineEstado(String estadoActual) {
  final estados = ["Pendiente", "En revisión", "Aprobada"];

  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
    child: Column(
      children: estados.map((estado) {
        final activo =
            estados.indexOf(estado) <= estados.indexOf(estadoActual);

        return Row(
          children: [
            Column(
              children: [
                Icon(
                  activo ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: activo
                      ? UIDEColors.conchevino
                      : Colors.grey,
                ),
                if (estado != estados.last)
                  Container(
                    width: 2,
                    height: 24,
                    color: activo
                        ? UIDEColors.conchevino
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              estado,
              style: TextStyle(
                fontWeight:
                    activo ? FontWeight.bold : FontWeight.normal,
                color: activo ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}

}
