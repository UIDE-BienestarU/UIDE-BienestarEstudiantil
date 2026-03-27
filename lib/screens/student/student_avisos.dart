import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/avisos_provider.dart';
import '../../models/aviso.dart';

class StudentAvisosScreen extends StatefulWidget {
  const StudentAvisosScreen({super.key});

  @override
  State<StudentAvisosScreen> createState() => _StudentAvisosScreenState();
}

class _StudentAvisosScreenState extends State<StudentAvisosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AvisosProvider>().loadPublicaciones());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvisosProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.loadPublicaciones(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final avisos = provider.avisosActivos;

    return Scaffold(
      body: avisos.isEmpty
          ? const Center(child: Text('No hay avisos activos'))
          : RefreshIndicator(
              onRefresh: () => provider.loadPublicaciones(),
              child: ListView.builder(
                itemCount: avisos.length,
                itemBuilder: (_, i) {
                  final aviso = avisos[i];

                  final imageUrl = buildFileUrl(aviso.imagen);
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: (imageUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            )
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
            ),
    );
  }
}
