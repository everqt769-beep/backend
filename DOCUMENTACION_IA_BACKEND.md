# Documentación de Integración IA en el Backend (Sistema de Reportes)

## 1. Objetivo
Se ha integrado la Inteligencia Artificial (API de Google Gemini 2.5 Flash) en el backend de Node.js con el propósito de ayudar a los funcionarios a **moderar y recategorizar automáticamente** los reportes enviados por los ciudadanos. La IA revisa el contexto del reporte original y sus imágenes adjuntas para:
- Detectar si un reporte es falso, una broma o una exageración.
- Clasificar el reporte bajo una prioridad (`alta`, `media`, `baja`).
- Proponer una categoría más apropiada basándose en las necesidades descritas.
- Justificar su decisión para que el admin entienda el razonamiento.

## 2. Nueva Arquitectura y Base de Datos

Para que el proceso sea transparente pero no afecte la consistencia de los datos, se crearon dos nuevas tablas en Supabase:

- **`analisis_ia`**: Funciona como un informe interno. Aquí se guarda en formato estructurado el dictamen final devuelto por Gemini (es_valido, prioridad, categoría sugerida y justificación).
- **`reportes_historial`**: Es una copia de seguridad o "log". Antes de que la IA o el backend sobrescriba el estado original del ciudadano (para cambiar su categoría o para rechazarlo por broma), se guarda un registro de su estado original en esta tabla.

## 3. Servicios y Controladores

### A. Servicio de IA (`src/services/ai.service.js`)
Se instaló la librería `@google/generative-ai`.
Este archivo posee la función principal `analizarReporte(reporte, imagenesUrls, categoriasExistentes)`:
- Recibe todo el objeto original en JSON del reporte (con su categoría base, áreas y usuario).
- Recibe la **lista completa de categorías existentes** en la BD para que la IA pueda elegir una existente o decidir crear una nueva.
- Recibe las imágenes y las procesa.
- Envía el *Prompt* pidiendo a la IA que devuelva: `es_valido`, `prioridad`, `categoria_sugerida` y `justificacion`.

### B. Rutas (`src/routes/reportes.routes.js`)
Se expusieron dos nuevos endpoints:
- **Ruta:** `POST /reportes/:id/analizar`
- **Permisos:** Protegido mediante `requireRole(['funcionario', 'admin'])`.
- El ciudadano o "vecino" no tiene acceso para activar la IA.

- **Ruta:** `GET /reportes/historial-ia`
- **Permisos:** Protegido mediante `requireRole(['admin'])`.
- Permite consultar el historial de los reportes originales vs cómo quedaron tras ser cambiados por la IA. Exclusivo para administradores.
- Incluye JOINs con `categorias(nombre)` y `estados(nombre, color)` tanto para el reporte actual como para los datos originales.

### C. Controlador Principal (`src/controllers/reportes.controller.js`)
El método `analizarReporteConIA` es el núcleo de este flujo. Sigue los siguientes pasos en orden:
1. **Extracción:** Saca de la BD el reporte completo, haciendo JOIN con categorías (incluyendo `prioridad_base`), áreas y leyendo las URLs de la tabla `adjuntos`.
2. **Carga de Categorías:** Consulta TODAS las categorías existentes para pasárselas a la IA.
3. **Evaluación:** Envía todo a `ai.service.js` para recibir el veredicto en formato JSON.
4. **Decisiones Automáticas (Reglas de Negocio):**
   - **Caso Inválido (broma):** Si Gemini dice que `es_valido: false`, el backend busca el ID de estado `'rechazado'` y lo aplica.
   - **Caso Cambio de Categoría (existe):** Si Gemini devuelve una categoría diferente que SÍ existe en la BD, la reasigna.
   - **Caso Categoría Nueva (no existe):** Si la categoría sugerida NO existe, el sistema **la crea automáticamente** en la tabla `categorias` con la prioridad mapeada (alta=1, media=2, baja=3).
5. **Respaldar Historial:** Si las decisiones del paso anterior desencadenan un cambio real, se inserta una fila en `reportes_historial` con los datos originales.
6. **Actualizar el Original:** Sobrescribe la tabla `reportes` directamente con la nueva categoría y/o el estado rechazado.
7. **Guardar el Análisis:** Guarda el dictamen completo (es_valido, prioridad, categoria_sugerida, justificacion) haciendo un `upsert` en la tabla `analisis_ia`.

## 4. Mapeo de Prioridad
La IA devuelve prioridad como texto (`"alta"`, `"media"`, `"baja"`), pero la tabla `categorias` usa `prioridad_base` como entero (1-3):

| IA devuelve | Se guarda como |
|---|---|
| `"alta"` | `prioridad_base: 1` |
| `"media"` | `prioridad_base: 2` |
| `"baja"` | `prioridad_base: 3` |

## 5. Respuesta del Historial para el Frontend
El endpoint `GET /reportes/historial-ia` devuelve objetos con esta estructura:
```json
{
    "id_historial": "uuid",
    "reporte_id": "uuid",
    "categoria_id_original": "uuid",
    "estado_id_original": "uuid",
    "fecha_modificacion": "timestamp",
    "reporte_actual": {
        "id_reporte": "uuid",
        "descripcion": "...",
        "categorias": { "nombre": "Categoría actual" },
        "estados": { "nombre": "Estado actual", "color": "#hex" }
    },
    "categoria_original": { "nombre": "Categoría antes del cambio" },
    "estado_original": { "nombre": "Estado antes del cambio", "color": "#hex" }
}
```

## 6. Requisitos para Funcionamiento
- Agregar la variable `GEMINI_API_KEY="tu-api-key"` en el archivo `.env`.
- Ejecutar el archivo SQL (`ejecutar_en_supabase.sql`) para tener listas las dos nuevas tablas (`analisis_ia` y `reportes_historial`).
