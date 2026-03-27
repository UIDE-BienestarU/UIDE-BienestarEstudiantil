import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/avisos_provider.dart';
import '../../models/aviso.dart';
import '../../theme/uide_colors.dart';
import 'student_dashboard.dart';


class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvisosProvider>();

    final objetosPerdidos =
        provider.avisosPorCategoria(CategoriaAviso.objetosPerdidos);
    final comunicados =
        provider.avisosPorCategoria(CategoriaAviso.comunicado);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _saludo(),
          const SizedBox(height: 24),

          _accionesRapidas(context),
          const SizedBox(height: 32),

          _titulo("Objetos perdidos"),
          objetosPerdidos.isEmpty
              ? _vacio("No hay objetos perdidos")
              : _itemObjetoPerdido(context, objetosPerdidos.first),

          const SizedBox(height: 32),

          _filaNoticias(),
          const SizedBox(height: 12),

          comunicados.isEmpty
              ? _vacio("No hay noticias")
              : Column(
                  children: comunicados
                      .map((a) => _itemNoticia(context, a))
                      .toList(),
                ),
        ],
      ),
    );
  }

  // ================= SALUDO =================

  Widget _saludo() {
    return Card(
      color: const Color.fromARGB(255, 13, 51, 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola, Juan Fuentes!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Es un buen día para seguir aprendiendo.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACCIONES RÁPIDAS =================

Widget _accionesRapidas(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _titulo("Acciones rápidas"),

      Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: [
          _accionItem(
            context,
            Icons.health_and_safety,
            textoCorto: "Salud",
            tipoReal: "Salud y bienestar físico",
          ),
          _accionItem(
            context,
            Icons.psychology,
            textoCorto: "Psicológico",
            tipoReal: "Apoyo psicológico y psicopedagógico",
          ),
          _accionItem(
            context,
            Icons.school,
            textoCorto: "Becas",
            tipoReal: "Becas y ayudas financieras",
          ),
          _accionItem(
            context,
            Icons.admin_panel_settings,
            textoCorto: "Académico",
            tipoReal: "Gestión académica y administrativa",
          ),
          _accionItem(
            context,
            Icons.sports_soccer,
            textoCorto: "Deportes",
            tipoReal: "Deportes y cultura",
          ),
        ],
      ),
    ],
  );
}


Widget _accionItem(
  BuildContext context,
  IconData icon, {
  required String textoCorto,
  required String tipoReal,
}) {
  return SizedBox(
    width: 45,
    child: _accion(context, icon, textoCorto, tipoReal),
  );
}



Widget _accion(
  BuildContext context,
  IconData icon,
  String textoCorto,
  String tipoReal,
) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(
            initialIndex: 2,       // pestaña "Nueva"
            tipoInicial: tipoReal // 🔥 tipo desde Home
          ),
        ),
      );
    },

    child: Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor:
              const Color.fromARGB(255, 21, 30, 88).withOpacity(0.1),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 27, 35, 104),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          textoCorto, // 👈 SOLO TEXTO CORTO
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}




  // ================= OBJETOS PERDIDOS =================

  Widget _itemObjetoPerdido(BuildContext context, Aviso aviso) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          aviso.imagen != null
              ? Image.file(
                  File(aviso.imagen!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 220,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.backpack, size: 60),
                  ),
                ),

          // TEXTO SOBRE IMAGEN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.6),
              child: Text(
                aviso.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ICONO COMENTARIOS
          Positioned(
            bottom: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.comment),
                color: UIDEColors.azul,
                onPressed: () => _modalComentarios(context, aviso),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _modalComentarios(BuildContext context, Aviso aviso) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Comentarios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (aviso.comentarios.isEmpty)
                const Text(
                  "No hay comentarios aún",
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...aviso.comentarios.map(
                  (c) => ListTile(
                    title: Text(c.texto),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context
                            .read<AvisosProvider>()
                            .eliminarComentario(aviso.id, c.id);
                      },
                    ),
                  ),
                ),

              const Divider(),
              _CajaComentario(aviso.id),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NOTICIAS =================

  Widget _filaNoticias() {
    return const Text(
      "Noticias",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: UIDEColors.conchevino,
      ),
    );
  }

Widget _itemNoticia(BuildContext context, Aviso aviso) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: const Border(
        left: BorderSide(width: 4, color: UIDEColors.conchevino),
      ),
      color: Theme.of(context).cardColor,
    ),
    child: ListTile(
      title: Text(
        aviso.titulo,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        aviso.contenido,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _detalle(context, aviso),
    ),
  );
}


  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: UIDEColors.conchevino,
          ),
        ),
      );

  Widget _vacio(String texto) =>
      Text(texto, style: const TextStyle(color: Colors.grey));

  // ================= DETALLE NOTICIA =================

  void _detalle(BuildContext context, Aviso aviso) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aviso.imagen != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.file(
                    File(aviso.imagen!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aviso.titulo,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(aviso.contenido),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CAJA COMENTARIOS =================

class _CajaComentario extends StatefulWidget {
  final String avisoId;

  const _CajaComentario(this.avisoId);

  @override
  State<_CajaComentario> createState() => _CajaComentarioState();
}

class _CajaComentarioState extends State<_CajaComentario> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Escribe un comentario...",
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: UIDEColors.azul),
          onPressed: () {
            if (_controller.text.trim().isEmpty) return;

            context.read<AvisosProvider>().agregarComentario(
                  widget.avisoId,
                  _controller.text.trim(),
                );

            _controller.clear();
          },
        ),
      ],
    );
  }
}
