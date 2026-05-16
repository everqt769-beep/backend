/// Constantes de configuración de la API y Supabase.
/// 
/// Aquí se centralizan todas las URLs y claves necesarias
/// para la comunicación con el backend y Supabase.
class ApiConstants {
  // ──────────────────────────────────────────────
  // Backend API (Railway)
  // ──────────────────────────────────────────────
  static const String baseUrl =
      'https://backend-production-fdab.up.railway.app/api';

  // ──────────────────────────────────────────────
  // Supabase - Reemplazar con tus credenciales
  // ──────────────────────────────────────────────
  static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';

  // ──────────────────────────────────────────────
  // Endpoints
  // ──────────────────────────────────────────────
  static const String estados = '$baseUrl/estados';
  static const String areas = '$baseUrl/areas';
  static const String categorias = '$baseUrl/categorias';
  static const String reportes = '$baseUrl/reportes';
  static const String adjuntos = '$baseUrl/adjuntos';
  static const String comentarios = '$baseUrl/comentarios';
  static const String asignaciones = '$baseUrl/asignaciones';
  static const String seguimiento = '$baseUrl/seguimiento';
  static const String usuarios = '$baseUrl/usuarios';

  // ──────────────────────────────────────────────
  // Supabase Storage Buckets
  // ──────────────────────────────────────────────
  static const String bucketFotos = 'fotos';
  static const String bucketVideos = 'videos';
  static const String bucketDocumentos = 'documentos';
}
