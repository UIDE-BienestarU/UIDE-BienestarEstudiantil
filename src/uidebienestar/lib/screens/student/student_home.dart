import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/avisos_provider.dart';
import '../../models/aviso.dart';
import '../../theme/uide_colors.dart';

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
          const SizedBox(height: 30),

          _titulo("Objetos perdidos"),
          objetosPerdidos.isEmpty
              ? _vacio("No hay objetos perdidos")
              : Column(
                  children: objetosPerdidos
                      .map((a) => _itemObjetoPerdido(context, a))
                      .toList(),
                ),

          const SizedBox(height: 40),

          _titulo("Comunicados importantes"),
          comunicados.isEmpty
              ? _vacio("No hay comunicados activos")
              : Column(
                  children: comunicados
                      .map((a) => _itemComunicado(context, a))
                      .toList(),
                ),
        ],
      ),
    );
  }

  // ================= UI BASE =================

  Widget _saludo() {
    return Card(
      color: UIDEColors.azul,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¡Hola!, Juan Fuentes",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Revisa comunicados y objetos perdidos",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
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
  }

  Widget _vacio(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(texto, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ================= OBJETOS PERDIDOS (CARD GRANDE) =================

  Widget _itemObjetoPerdido(BuildContext context, Aviso aviso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN GRANDE
          aviso.imagen != null
              ? Image.file(
                  File(aviso.imagen!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.backpack, size: 60),
                  ),
                ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aviso.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _fecha(aviso.fechaCreacion),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // ICONO DE COMENTARIOS
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () => _detalle(context, aviso),
                    ),
                    Text("${aviso.comentarios.length} comentarios"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMUNICADOS (NORMAL) =================

  Widget _itemComunicado(BuildContext context, Aviso aviso) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: aviso.imagen != null
            ? Image.file(File(aviso.imagen!), width: 50, fit: BoxFit.cover)
            : const Icon(Icons.campaign),
        title: Text(aviso.titulo),
        subtitle: Text(
          aviso.contenido,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _detalle(context, aviso),
      ),
    );
  }

  // ================= DETALLE + COMENTARIOS =================

  void _detalle(BuildContext context, Aviso aviso) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                const SizedBox(height: 12),

                if (aviso.categoria == CategoriaAviso.objetosPerdidos) ...[
                  const Divider(),
                  const Text(
                    "Comentarios",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (aviso.comentarios.isEmpty)
                    const Text(
                      "Aún no hay comentarios",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...aviso.comentarios.map(
                      (c) => ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text(c.texto),
                        subtitle: Text(
                          _fecha(c.fecha),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<AvisosProvider>().eliminarComentario(
                              aviso.id,
                              c.id,
                            );
                          },
                        ),
                      ),
                    ),
                  _CajaComentario(aviso.id),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fecha(DateTime f) =>
      "${f.day}/${f.month}/${f.year}";
}

// ================= CAJA COMENTARIOS =================

class _CajaComentario extends StatefulWidget {
  final String avisoId;
  const _CajaComentario(this.avisoId);

  @override
  State<_CajaComentario> createState() => _CajaComentarioState();
}

class _CajaComentarioState extends State<_CajaComentario> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration:
                const InputDecoration(hintText: "Escribe un comentario"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_ctrl.text.trim().isEmpty) return;
            context
                .read<AvisosProvider>()
                .agregarComentario(widget.avisoId, _ctrl.text.trim());
            _ctrl.clear();
          },
        ),
      ],
    );
  }
}
