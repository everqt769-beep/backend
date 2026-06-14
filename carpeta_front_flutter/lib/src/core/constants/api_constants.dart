/// Constantes de configuración de la API y Supabase.
///
/// Aquí se centralizan todas las URLs y claves necesarias
/// para la comunicación con el backend y Supabase.
class ApiConstants {
  // ──────────────────────────────────────────────
  // Backend API (Railway); se cambio a render
  // ──────────────────────────────────────────────
  static const String baseUrl =
      //'https://backend-production-8c234.up.railway.app/api';
      'https://backend-kd3y.onrender.com/api';

  // ──────────────────────────────────────────────
  // Supabase - Reemplazar con tus credenciales
  // ──────────────────────────────────────────────
  static const String supabaseUrl = 'https://nzsyekwmaalmrugkowav.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im56c3lla3dtYWFsbXJ1Z2tvd2F2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxNzczNjYsImV4cCI6MjA5Mjc1MzM2Nn0.ng5QHYkg77Tja3K8JLNvE_krKTWPogffwDJymt9_Lzc';

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
  
  // Endpoints de IA
  static const String analisisIa = '$baseUrl/reportes/analizar'; // POST a /reportes/:id/analizar
  static const String reportesHistorial = '$baseUrl/reportes/historial-ia'; // GET

  // ──────────────────────────────────────────────
  // Endpoints de Bloqueos
  // ──────────────────────────────────────────────
  static const String bloqueosVerificar = '$baseUrl/bloqueos/verificar';
  static const String bloqueosConfig = '$baseUrl/bloqueos/config';
  static const String bloqueosUsuarios = '$baseUrl/bloqueos/usuarios-bloqueados';
  static const String bloqueosEstadisticas = '$baseUrl/bloqueos/estadisticas';
  static const String bloqueosHistorial = '$baseUrl/bloqueos/historial'; // + /:usuario_id
  static const String bloqueosBloquear = '$baseUrl/bloqueos/bloquear'; // + /:usuario_id
  static const String bloqueosDesbloquear = '$baseUrl/bloqueos/desbloquear'; // + /:usuario_id

  // ──────────────────────────────────────────────
  // Endpoints de Dashboard
  // ──────────────────────────────────────────────
  static const String dashboardConteos = '$baseUrl/dashboard/conteos';
  static const String dashboardResumen = '$baseUrl/dashboard/resumen-diario';
  static const String dashboardEstadisticas = '$baseUrl/dashboard/estadisticas';
  static const String dashboardRechazados = '$baseUrl/dashboard/rechazados';
  static const String dashboardTendencia = '$baseUrl/dashboard/tendencia-mensual';
  static const String dashboardGenerarReporte = '$baseUrl/dashboard/generar-reporte';

  // ──────────────────────────────────────────────
  // Supabase Storage Buckets
  // ──────────────────────────────────────────────
  static const String bucketFotos = 'fotos';
  static const String bucketVideos = 'videos';
  static const String bucketDocumentos = 'documentos';
}