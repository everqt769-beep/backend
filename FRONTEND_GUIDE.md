# Guía de Integración Frontend - API Backend de Reportes

Este documento detalla todos los endpoints disponibles en el backend de Node.js, qué datos requieren y cómo se deben consumir desde el Frontend.

## 1. Configuración Base y Autenticación

- **Base URL:** `http://localhost:3000/api`
- **Autenticación:** El sistema está integrado con **Supabase Auth**. El Frontend debe autenticar al usuario usando el SDK de Supabase (ej: `supabase.auth.signInWithPassword()`).
- **Headers:** Las rutas protegidas requieren que se envíe el token JWT del usuario en las peticiones al backend:
  ```http
  Authorization: Bearer <TOKEN_JWT>
  ```
- *Nota:* El rol del usuario (`ciudadano`, `funcionario`, `admin`) es verificado automáticamente por el backend para restringir acceso.

---

## 2. Maestros (Catálogos)
Datos que el Frontend necesita cargar inicialmente para llenar selectores y formularios.

### **Estados**
- `GET /api/estados` -> Devuelve todos los estados.
- `GET /api/estados/:entidad` -> Devuelve los estados de una entidad específica (ej: `/api/estados/reporte`).

### **Áreas**
- `GET /api/areas` -> Lista de áreas municipales (Servicios Básicos, Alumbrado, etc.).
- `GET /api/areas/:id` -> Detalle de un área.

### **Categorías**
- `GET /api/categorias` -> Lista de todas las categorías con los datos de sus áreas asociadas.
- `GET /api/categorias/area/:areaId` -> Devuelve solo las categorías pertenecientes a un ID de área específico.

---

## 3. Usuarios
*Requiere Autenticación*

- `GET /api/usuarios/perfil`
  - Devuelve los datos del usuario actual autenticado, junto a su área y estado.
- `PUT /api/usuarios/perfil`
  - Modifica los datos del usuario actual (ej. teléfono).
  - *Body:* `{ "telefono": "12345678" }` (Nota: El rol y estado no pueden cambiarse por esta vía).
- `GET /api/usuarios`
  - Lista todos los usuarios (*Solo para rol `admin`*).

---

## 4. Reportes
*Todas las peticiones a reportes requieren Autenticación*

- `GET /api/reportes`
  - Obtiene una lista de todos los reportes ordenados del más reciente al más antiguo.
  - Incluye información de usuario, categoría, área y estado actual.
- `GET /api/reportes/:id`
  - Devuelve el detalle exhaustivo de un reporte.
  - **Incluye en la misma respuesta:** `adjuntos`, `comentarios` y el historial de `seguimiento`.

- `POST /api/reportes`
  - Crea un nuevo reporte.
  - El backend asignará automáticamente el estado `pendiente` y creará un registro en el historial (`seguimiento`).
  - *Body esperado:*
    ```json
    {
      "categoria_id": "uuid",
      "descripcion": "Descripción del problema",
      "latitud": -16.5000000,
      "longitud": -68.1192930,
      "direccion": "Av. Ejemplo #123"
    }
    ```

- `PATCH /api/reportes/:id/estado`
  - Cambia el estado del reporte (*Solo `funcionario` o `admin`*).
  - Genera automáticamente un registro en `seguimiento`.
  - *Body esperado:*
    ```json
    {
      "estado_codigo": "en_revision",
      "descripcion_seguimiento": "Comenzando la revisión del problema en campo" 
    }
    ```

---

## 5. Adjuntos (Fotos, Videos, Documentos)

> **Flujo recomendado:** 
> 1. El Frontend sube el archivo directamente a **Supabase Storage** (bucket `fotos` o `videos`) usando el SDK de Supabase.
> 2. Obtiene la URL pública o la ruta en Storage.
> 3. Llama a este backend para registrar la metadata en la Base de Datos.

- `GET /api/adjuntos/reporte/:reporteId`
  - Obtiene los adjuntos vinculados a un reporte específico.
- `POST /api/adjuntos` (*Requiere Auth*)
  - Registra un nuevo archivo subido por un usuario.
  - Por defecto el estado será `pendiente_mod` (Esperando moderación).
  - *Body esperado:*
    ```json
    {
      "reporte_id": "uuid",
      "tipo": "imagen", 
      "url": "URL_DEL_STORAGE_AQUI",
      "nombre_archivo": "foto1.jpg",
      "tamano_bytes": 102400,
      "descripcion": "Foto del bache en la calle"
    }
    ```
- `PATCH /api/adjuntos/:id/moderacion` (*Solo `funcionario` o `admin`*)
  - Modera una evidencia.
  - *Body esperado:* `{ "estado_codigo": "aprobado_mod" }` o `{ "estado_codigo": "rechazado_mod" }`

---

## 6. Asignaciones
*Para la gestión interna de trabajadores*

- `GET /api/asignaciones/mis-asignaciones` (*Solo `funcionario`*)
  - Devuelve todos los reportes asignados al funcionario que realiza la petición.
- `POST /api/asignaciones` (*Solo `funcionario` o `admin`*)
  - Asigna a un funcionario para resolver un reporte.
  - Automáticamente cambia el estado del reporte a `asignado` y deja constancia en `seguimiento`.
  - *Body esperado:*
    ```json
    {
      "reporte_id": "uuid",
      "funcionario_id": "uuid"
    }
    ```

---

## 7. Comentarios (Chat o Historial)
*Requiere Autenticación*

- `GET /api/comentarios/reporte/:reporteId`
  - Trae la cadena de comentarios de un reporte.
- `POST /api/comentarios`
  - Registra un comentario nuevo.
  - *Body esperado:*
    ```json
    {
      "reporte_id": "uuid",
      "texto": "Mensaje del comentario",
      "tipo": "publico", 
      "padre_id": null 
    }
    ```
  - *Tipos válidos:* `publico` (Ciudadanos/Funcionarios), `interno` (Solo Funcionarios/Admin), `respuesta_oficial` (Solo Funcionarios/Admin). El backend fuerza el tipo `publico` si un ciudadano intenta enviar otro tipo. `padre_id` sirve para responder a un comentario anterior.

---

## 8. Seguimiento (Trazabilidad)
*El seguimiento se nutre mayormente de forma automática (cuando se crea un reporte, se cambia el estado, o se asigna), pero se puede consultar:*

- `GET /api/seguimiento/reporte/:reporteId` (*Requiere Auth*)
  - Obtiene una línea de tiempo (timeline) cronológica con todo lo ocurrido sobre el reporte. Contiene quién hizo el evento, en qué fecha, y cuál fue el nuevo estado. Útil para mostrar un componente visual de "Evolución del Reporte" en el Frontend.
