# 🏗️ VecinApp - Guía de Setup Flutter

## Estructura de Carpetas

Todos estos archivos deben ir dentro de la carpeta `lib/` de tu proyecto Flutter.

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── services/
│       ├── api_service.dart
│       ├── auth_service.dart
│       └── storage_service.dart
├── models/
│   ├── area.dart
│   ├── categoria.dart
│   ├── estado.dart
│   ├── usuario.dart
│   ├── reporte.dart
│   ├── adjunto.dart
│   ├── comentario.dart
│   ├── seguimiento.dart
│   └── asignacion.dart
├── providers/
│   ├── auth_provider.dart
│   ├── reportes_provider.dart
│   └── catalogos_provider.dart
├── ciudadano/
│   ├── screens/
│   │   ├── ciudadano_home_screen.dart
│   │   ├── crear_reporte_screen.dart
│   │   ├── detalle_reporte_screen.dart
│   │   ├── mis_reportes_screen.dart
│   │   └── mapa_selector_screen.dart
│   └── widgets/
│       ├── reporte_card.dart
│       ├── timeline_widget.dart
│       ├── comentarios_widget.dart
│       └── adjuntos_widget.dart
├── funcionario/
│   └── screens/
│       ├── funcionario_home_screen.dart
│       ├── mapa_reportes_screen.dart
│       ├── tabla_reportes_screen.dart
│       └── detalle_reporte_funcionario_screen.dart
├── admin/
│   └── screens/
│       ├── admin_home_screen.dart
│       ├── admin_usuarios_screen.dart
│       └── admin_auditoria_screen.dart
├── auth/
│   └── screens/
│       ├── login_screen.dart
│       └── register_screen.dart
└── shared/
    └── widgets/
        ├── loading_widget.dart
        ├── estado_badge.dart
        └── empty_state_widget.dart
```

## Dependencias requeridas en `pubspec.yaml`

Agrega estas dependencias a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.8.0

  # Estado/Provider
  provider: ^6.1.2

  # HTTP
  http: ^1.2.1

  # Mapas OpenStreetMap
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  
  # Seleccionar ubicación
  geolocator: ^13.0.2
  geocoding: ^3.0.0

  # Almacenamiento local
  shared_preferences: ^2.3.3

  # Seleccionar imágenes/archivos
  image_picker: ^1.1.2
  file_picker: ^8.1.3

  # Formatos de fecha
  intl: ^0.19.0
  
  # Iconos
  flutter_svg: ^2.0.10+1
  
  # URL launcher
  url_launcher: ^6.3.1

  # Permisos
  permission_handler: ^11.3.1

  # Animaciones
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0

  # Fuentes
  google_fonts: ^6.2.1

  # Cacheo de imágenes
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Configuración de Supabase

En tu proyecto de Supabase necesitas las credenciales:
- `SUPABASE_URL`: La URL de tu proyecto Supabase
- `SUPABASE_ANON_KEY`: La clave anón/pública

Estas se configuran en `lib/core/constants/api_constants.dart`.

## Plataformas

### Android
En `android/app/src/main/AndroidManifest.xml` agrega:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS
En `ios/Runner/Info.plist` agrega:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>VecinApp necesita tu ubicación para reportar incidentes</string>
<key>NSCameraUsageDescription</key>
<string>VecinApp necesita la cámara para tomar fotos de evidencia</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>VecinApp necesita acceso a fotos para adjuntar evidencia</string>
```

### Web
No requiere configuración especial adicional. Flutter Web funciona directamente.

## Backend URL (Railway)

El backend ya está desplegado en:
```
https://backend-production-fdab.up.railway.app/
```

Los endpoints disponibles son:
- `/api/estados`
- `/api/areas`
- `/api/categorias`
- `/api/usuarios/perfil`
- `/api/reportes`
- `/api/adjuntos`
- `/api/comentarios`
- `/api/asignaciones`
- `/api/seguimiento`

## Ejecutar el proyecto

```bash
flutter pub get
flutter run -d chrome     # Para Web
flutter run -d android    # Para Android
flutter run -d ios        # Para iOS
```
