import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/uide_colors.dart';
import '../../providers/notificaciones_provider.dart';

class StudentNotificacionesScreen extends StatefulWidget {
  const StudentNotificacionesScreen({super.key});

  @override
  State<StudentNotificacionesScreen> createState() =>
      _StudentNotificacionesScreenState();
}

class _StudentNotificacionesScreenState
    extends State<StudentNotificacionesScreen> {
  bool _onlyUnread = false;

  // ✅ Locks para evitar duplicados
  bool _loadingList = false;
  final Set<String> _marking = {};

  // ✅ Debounce real
  Timer? _toggleDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _safeLoad(unread: _onlyUnread));
  }

  @override
  void dispose() {
    _toggleDebounce?.cancel();
    super.dispose();
  }

  Future<void> _safeLoad({required bool unread}) async {
    if (_loadingList) return;
    _loadingList = true;

    try {
      await context.read<NotificacionesProvider>().load(unread: unread);
    } finally {
      _loadingList = false;
    }
  }

  Future<void> _safeMarkRead(String id) async {
    if (_marking.contains(id)) return;

    setState(() => _marking.add(id));
    try {
      await context.read<NotificacionesProvider>().markRead(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _marking.remove(id));
    }
  }

  void _toggleUnread() {
    // ✅ debounce: si el usuario spamea, solo ejecuta la última intención
    _toggleDebounce?.cancel();
    _toggleDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _onlyUnread = !_onlyUnread);
      _safeLoad(unread: _onlyUnread);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionesProvider>();

    return Scaffold(
      backgroundColor: UIDEColors.grisClaro,
      appBar: AppBar(
        backgroundColor: UIDEColors.conchevino,
        foregroundColor: Colors.white,
        title: const Text("Notificaciones"),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                provider.loading ? null : () => _safeLoad(unread: _onlyUnread),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Header filtro =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _onlyUnread ? 'Mostrando: no leídas' : 'Mostrando: todas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: provider.loading ? null : _toggleUnread,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _onlyUnread
                          ? UIDEColors.conchevino.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _onlyUnread
                            ? UIDEColors.conchevino.withOpacity(0.35)
                            : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _onlyUnread
                              ? Icons.mark_email_unread_rounded
                              : Icons.all_inbox_rounded,
                          size: 18,
                          color: _onlyUnread
                              ? UIDEColors.conchevino
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _onlyUnread ? 'Solo no leídas' : 'Todas',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _onlyUnread
                                ? UIDEColors.conchevino
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Lista =====
          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.loading && provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIDEColors.conchevino,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: provider.loading
                                ? null
                                : () => _safeLoad(unread: _onlyUnread),
                            child: const Text('Reintentar'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (provider.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _safeLoad(unread: _onlyUnread),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 180),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.notifications_off_rounded,
                                  size: 54, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(
                                'No hay notificaciones',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Desliza hacia abajo para actualizar.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _safeLoad(unread: _onlyUnread),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final n = provider.items[index];
                      final isMarking = _marking.contains(n.id);

                      final bg =
                          n.leido ? Colors.white : const Color(0xFFFFF6F6);
                      final border = n.leido
                          ? Colors.black.withOpacity(0.06)
                          : UIDEColors.conchevino.withOpacity(0.30);

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          if (!n.leido) await _safeMarkRead(n.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon bubble
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      UIDEColors.conchevino.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  n.leido
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_rounded,
                                  color: UIDEColors.conchevino,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            (n.titulo?.isNotEmpty ?? false)
                                                ? n.titulo!
                                                : "Notificación",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.grey.shade900,
                                            ),
                                          ),
                                        ),
                                        if (!n.leido && !isMarking)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            decoration: const BoxDecoration(
                                              color: UIDEColors.conchevino,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.mensaje,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule_rounded,
                                            size: 14,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Text(
                                          _timeAgo(n.fechaEnvio),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isMarking)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        if (!n.leido && !isMarking)
                                          Text(
                                            "Marcar leída",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: UIDEColors.conchevino,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }
}
