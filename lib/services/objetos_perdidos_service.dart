import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/objeto_perdido.dart';
import 'api_client.dart';

class ObjetosPerdidosPage {
  final List<ObjetoPerdido> items;
  final int page;
  final int limit;
  final bool hasMore;

  ObjetosPerdidosPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

class ObjetosPerdidosService {
  static Future<ObjetosPerdidosPage> getObjetos({
    int page = 1,
    int limit = 20,
    String? estado,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/objetos-perdidos/ver-objetos',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (estado != null && estado.isNotEmpty) 'estado': estado,
        },
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print('GET /objetos-perdidos/ver-objetos -> ${res.statusCode}');
        // ignore: avoid_print
        print(res.data);
      }

      final body = res.data;

      // 1) Normaliza a un "List" venga como venga
      final List<dynamic> rawList = _extractList(body);

      final items = rawList
          .whereType<Map>()
          .map((m) => ObjetoPerdido.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      // hasMore: si el backend no manda meta, usamos regla simple
      bool hasMore = items.length >= limit;

      // intenta meta común
      final meta = _extractMeta(body);
      if (meta != null) {
        final totalPages = _toInt(meta['totalPages'] ?? meta['total_pages']);
        if (totalPages != null) hasMore = page < totalPages;

        final total = _toInt(meta['total']);
        if (total != null) {
          final already = page * limit;
          hasMore = already < total;
        }
      }

      return ObjetosPerdidosPage(
        items: items,
        page: page,
        limit: limit,
        hasMore: hasMore,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && (data['message'] ?? data['error']) != null)
          ? (data['message'] ?? data['error']).toString()
          : 'Error al listar objetos perdidos';
      throw Exception(msg);
    }
  }

  static List<dynamic> _extractList(dynamic body) {
    // Casos soportados:
    //  - [ ... ]
    //  - { data: [ ... ] }
    //  - { data: { items:[...] } }
    //  - { data: { rows:[...] } }
    //  - { items:[...] }
    //  - { objetos:[...] }
    //  - { results:[...] }
    //  - { data: { data:[...] } } (doble data)
    if (body is List) return body;

    if (body is Map) {
      dynamic d = body['data'];

      // doble data
      if (d is Map && d['data'] is List) return List<dynamic>.from(d['data']);

      if (d is List) return List<dynamic>.from(d);

      if (d is Map) {
        for (final key in ['items', 'rows', 'results', 'objetos']) {
          if (d[key] is List) return List<dynamic>.from(d[key]);
        }
      }

      for (final key in ['items', 'rows', 'results', 'objetos']) {
        if (body[key] is List) return List<dynamic>.from(body[key]);
      }
    }

    return const [];
  }

  static Map<String, dynamic>? _extractMeta(dynamic body) {
    if (body is Map && body['meta'] is Map) {
      return Map<String, dynamic>.from(body['meta']);
    }
    if (body is Map && body['pagination'] is Map) {
      return Map<String, dynamic>.from(body['pagination']);
    }
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
