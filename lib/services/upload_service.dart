import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UploadResult {
  final String url; // ej: /Uploads/1700000000.pdf
  final String? mimeType;
  final int? size;
  final String? originalName;

  UploadResult({
    required this.url,
    this.mimeType,
    this.size,
    this.originalName,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'].toString(),
      mimeType: json['mimeType']?.toString(),
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse('${json['size']}'),
      originalName: json['originalName']?.toString(),
    );
  }
}

class UploadService {
  static Future<UploadResult> uploadDocumento(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final form = FormData.fromMap({
      // ✅ tu backend espera upload.single('documento')
      'documento': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      // ✅ OJO: como baseUrl ya incluye /api,
      // el endpoint correcto es /upload/upload
      final res = await ApiClient.dio.post(
        '/upload/upload',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = res.data;

      // tu API devuelve { success, message, data: {...} }
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);

      return UploadResult.fromJson(data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Error al subir archivo';
      throw Exception(msg);
    }
  }
}
