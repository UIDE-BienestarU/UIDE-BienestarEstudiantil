import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/avisos_provider.dart';
import '../models/comentario.dart';
import '../services/socket_client.dart';
import '../theme/uide_colors.dart';

class ComentariosObjetoModal extends StatefulWidget {
  final String objetoId;
  const ComentariosObjetoModal({super.key, required this.objetoId});

  @override
  State<ComentariosObjetoModal> createState() => _ComentariosObjetoModalState();
}

class _ComentariosObjetoModalState extends State<ComentariosObjetoModal> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await SocketClient.I.connect();
      SocketClient.I.joinObjeto(widget.objetoId);

      SocketClient.I.onComentarioNuevo((payload) {
        // payload: lo que tú emites en emitComentarioObjeto(objetoId, payload)
        // ejemplo esperado:
        // { id, objeto_id, mensaje, createdAt, autor: { nombre_completo } }

        final autor = (payload['autor'] ?? {}) as Map;
        final nombre = (autor['nombre_completo'] ?? 'Estudiante').toString();

        final c = Comentario(
          id: payload['id']?.toString(),
          texto: (payload['mensaje'] ?? '').toString(),
          fecha: DateTime.tryParse((payload['createdAt'] ?? '').toString()) ??
              DateTime.now(),
          autorNombre: nombre,
          autorIniciales: _initials(nombre),
        );

        context
            .read<AvisosProvider>()
            .pushComentarioFromSocket(widget.objetoId, c);
      });
    });
  }

  @override
  void dispose() {
    SocketClient.I.leaveObjeto(widget.objetoId);
    SocketClient.I.offComentarioNuevo();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    final out = (a + b).toUpperCase();
    return out.isEmpty ? '?' : out;
  }

  @override
  Widget build(BuildContext context) {
    final aviso = context.watch<AvisosProvider>().avisoPorId(widget.objetoId);
    final comentarios = aviso.comentarios;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Comentarios",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: comentarios.isEmpty
                  ? const Center(child: Text("No hay comentarios aún"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comentarios.length,
                      itemBuilder: (_, i) {
                        final c = comentarios[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    UIDEColors.conchevino.withOpacity(0.1),
                                child: Text(
                                  c.autorIniciales,
                                  style: const TextStyle(
                                      color: UIDEColors.conchevino,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.autorNombre,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text(c.texto),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _CajaComentario(objetoId: widget.objetoId),
            ),
          ],
        ),
      ),
    );
  }
}

class _CajaComentario extends StatefulWidget {
  final String objetoId;
  const _CajaComentario({required this.objetoId});

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
            decoration:
                const InputDecoration(hintText: "Escribe un comentario..."),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            final txt = _controller.text.trim();
            if (txt.isEmpty) return;

            // aquí tú decides:
            // Opción A: crear por REST, y backend emitirá por socket
            await context
                .read<AvisosProvider>()
                .crearComentario(widget.objetoId, txt);

            _controller.clear();
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
