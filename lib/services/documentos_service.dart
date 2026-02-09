import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UploadedFile {
  final String url; // ej: /Uploads/1700000000.pdf
  final String originalName;
  final String mimeType;
  final int size;

  const UploadedFile({
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.size,
  });
}

/// Payload que espera tu backend para registrar documentos
class DocumentoPayload {
  final String urlArchivo;
  final String nombreDocumento;
  final bool obligatorio;

  const DocumentoPayload({
    required this.urlArchivo,
    required this.nombreDocumento,
    required this.obligatorio,
  });

  Map<String, dynamic> toJson() => {
        "url_archivo": urlArchivo,
        "nombre_documento": nombreDocumento,
        "obligatorio": obligatorio,
      };
}

class DocumentosService {
  /// ✅ Subir UN archivo a Uploads
  /// Endpoint REAL: /api/upload/upload
  /// En Flutter (baseUrl ya trae /api): /upload/upload
  static Future<UploadedFile> uploadToUploads({
    required File file,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final form = FormData.fromMap({
      'documento': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    try {
      final res = await ApiClient.dio.post(
        '/upload/upload', // ✅ FIX
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = res.data;
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);

      final url = (data['url'] ?? '').toString();
      if (url.isEmpty) {
        throw Exception('No se recibió url del archivo subido');
      }

      return UploadedFile(
        url: url,
        originalName: (data['originalName'] ?? fileName).toString(),
        mimeType: (data['mimeType'] ?? '').toString(),
        size: int.tryParse((data['size'] ?? 0).toString()) ?? 0,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al subir archivo';
      throw Exception(msg);
    }
  }

  /// ✅ Registrar documentos en una solicitud
  /// Backend: POST /solicitudes/:id/documentos
  /// (en server.js está montado en /api + solicitudesRoutes)
  static Future<void> addDocumentos({
    required int solicitudId,
    required List<DocumentoPayload> documentos,
  }) async {
    if (documentos.isEmpty) return;

    try {
      await ApiClient.dio.post(
        '/solicitudes/$solicitudId/documentos',
        data: {
          "documentos": documentos.map((d) => d.toJson()).toList(),
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al registrar documentos';
      throw Exception(msg);
    }
  }
}
