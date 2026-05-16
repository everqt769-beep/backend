import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

/// Servicio para subir archivos a Supabase Storage.
///
/// El flujo es:
/// 1. Subir archivo a Storage → obtener URL pública
/// 2. Registrar metadatos en el backend vía API
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────
  // Subir imagen desde archivo (mobile)
  // ─────────────────────────────────────────────
  Future<String> uploadImage({
    required File file,
    required String reporteId,
  }) async {
    final fileName =
        '${reporteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$reporteId/$fileName';

    await _client.storage
        .from(ApiConstants.bucketFotos)
        .upload(path, file);

    final url = _client.storage
        .from(ApiConstants.bucketFotos)
        .getPublicUrl(path);

    return url;
  }

  // ─────────────────────────────────────────────
  // Subir imagen desde bytes (web)
  // ─────────────────────────────────────────────
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String reporteId,
    required String fileName,
  }) async {
    final path =
        '$reporteId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage
        .from(ApiConstants.bucketFotos)
        .uploadBinary(path, bytes);

    final url = _client.storage
        .from(ApiConstants.bucketFotos)
        .getPublicUrl(path);

    return url;
  }

  // ─────────────────────────────────────────────
  // Subir video
  // ─────────────────────────────────────────────
  Future<String> uploadVideo({
    required File file,
    required String reporteId,
  }) async {
    final fileName =
        '${reporteId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final path = '$reporteId/$fileName';

    await _client.storage
        .from(ApiConstants.bucketVideos)
        .upload(path, file);

    final url = _client.storage
        .from(ApiConstants.bucketVideos)
        .getPublicUrl(path);

    return url;
  }

  // ─────────────────────────────────────────────
  // Subir documento
  // ─────────────────────────────────────────────
  Future<String> uploadDocument({
    required File file,
    required String reporteId,
    required String originalName,
  }) async {
    final path =
        '$reporteId/${DateTime.now().millisecondsSinceEpoch}_$originalName';

    await _client.storage
        .from(ApiConstants.bucketDocumentos)
        .upload(path, file);

    final url = _client.storage
        .from(ApiConstants.bucketDocumentos)
        .getPublicUrl(path);

    return url;
  }

  // ─────────────────────────────────────────────
  // Eliminar archivo de storage
  // ─────────────────────────────────────────────
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
