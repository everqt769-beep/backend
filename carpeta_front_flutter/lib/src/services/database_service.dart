import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  // En lib/src/services/auth_service.dart
  Future<String?> getCurrentUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      // Asumo que tienes una tabla 'usuarios' donde guardas el rol
      final response = await _client
          .from('usuarios')
          .select('rol')
          .eq('id_usuario', user.id)
          .single();
      return response['rol'] as String?;
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
      return null;
    }
  }

  // En lib/src/services/database_service.dart

  // Importa tu servicio de autenticación si es necesario
    // import 'auth_service.dart';
  
    // En lib/src/services/database_service.dart
  
  Future<List<Map<String, dynamic>>> getReports() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');
  
    try {
      // 1. Obtener el rol del usuario directamente desde la tabla 'usuarios'.
      final userProfile = await _client
          .from('usuarios')
          .select('rol')
          .eq('id_usuario', userId)
          .single();
      
      final userRole = userProfile['rol'] as String?;
  
      // 2. Empezar a construir la consulta para los reportes.
      var query = _client
          .from('reportes')
          .select('*, categoria_id(nombre), estado_id(nombre, color)');
  
      // 3. ¡AQUÍ APLICAMOS TU LÓGICA!
      // Si el usuario es un ciudadano, filtramos por su ID.
      if (userRole == 'ciudadano') {
        query = query.eq('usuario_id', userId);
      }
      // Si es funcionario o admin, no aplicamos el filtro y dejamos
      // que las Políticas de Seguridad (RLS) del backend decidan qué puede ver.
  
      // 4. Ejecutar la consulta y devolver los resultados.
      final response = await query.order('fecha_creacion', ascending: false);
  
      return List<Map<String, dynamic>>.from(response);
  
    } catch (e) {
      // Añadimos un poco más de detalle al error para facilitar la depuración.
      throw Exception('Error al obtener los reportes: $e');
    }
  }
  
  



  // Obtiene los reportes del usuario actual junto con su categoría y estado.
  Future<List<Map<String, dynamic>>> getReportsForUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado.');
    }

    try {
      final response = await _client
          .from('reportes')
          .select('*, categoria_id(nombre), estado_id(nombre, color)')
          .eq('usuario_id', userId)
          .order('fecha_creacion', ascending: false);
          
      // La respuesta ya es una lista de mapas, no es necesario decodificar JSON.
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      // Manejo de errores más específico para Supabase
      throw Exception('Error al obtener los reportes: $e');
    }
  }

  // Crea un nuevo incidente para el usuario actual.
  Future<Map<String, dynamic>> createIncident({
    required String categoryId,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado.');
    }

    final body = {
      'usuario_id': userId,
      'categoria_id': categoryId,
      'descripcion': description,
      'latitud': latitude,
      'longitud': longitude,
      'direccion': address ?? 'Dirección no proporcionada',
      // Asumimos un estado inicial. Esto debería venir de la tabla `estados`.
      // Por ahora, lo dejamos en null para que la DB use su default o un trigger.
    };

    try {
      final response = await _client.from('reportes').insert(body).select().single();
      return response;
    } catch (e) {
      throw Exception('Error al crear el incidente: $e');
    }
  }

  // Registra un archivo adjunto a un reporte.
  Future<void> registerAttachment({
    required String reportId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    String type = 'imagen',
  }) async {
     final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado.');
    }

    final body = {
      'reporte_id': reportId,
      'usuario_id': userId,
      'tipo': type,
      'url': fileUrl,
      'nombre_archivo': fileName,
      'tamano_bytes': fileSize,
    };

    try {
      await _client.from('adjuntos').insert(body);
    } catch (e) {
      throw Exception('Error al registrar el adjunto: $e');
    }
  }

  // Obtiene todas las categorías disponibles.
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client.from('categorias').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al cargar las categorías: $e');
    }
  }
}
