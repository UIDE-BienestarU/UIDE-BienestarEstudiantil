import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//IMPORTS
import '../../providers/avisos_provider.dart';

class StudentAvisosScreen extends StatelessWidget {
  const StudentAvisosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final avisos =
        context.watch<AvisosProvider>().avisosActivos;

    return Scaffold(
      body: avisos.isEmpty
          ? const Center(child: Text('No hay avisos activos'))
          : ListView.builder(
              itemCount: avisos.length,
              itemBuilder: (_, i) {
                final aviso = avisos[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: aviso.imagen != null
                        ? Image.file(File(aviso.imagen!), width: 50)
                        : const Icon(Icons.campaign),
                    title: Text(aviso.titulo),
                    subtitle: Text(
                      aviso.contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
