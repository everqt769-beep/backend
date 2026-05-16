# Documentación de Integración IA en el Backend (Sistema de Reportes)

## 1. Objetivo
Se ha integrado la Inteligencia Artificial (API de Google Gemini 1.5 Flash) en el backend de Node.js con el propósito de ayudar a los funcionarios a **moderar y recategorizar automáticamente** los reportes enviados por los ciudadanos. La IA revisa el contexto del reporte original y sus imágenes adjuntas para:
- Detectar si un reporte es falso, una broma o una exageración.
- Clasificar el reporte bajo una prioridad (`alta`, `media`, `baja`).
- Proponer una categoría más apropiada basándose en las necesidades descritas.

## 2. Nueva Arquitectura y Base de Datos

Para que el proceso sea transparente pero no afecte la consistencia de los datos, se crearon dos nuevas tablas en Supabase:

- **`analisis_ia`**: Funciona como un informe secreto. Aquí se guarda en formato estructurado el dictamen final devuelto por Gemini.
- **`reportes_historial`**: Es una copia de seguridad o "log". Antes de que la IA o el backend sobrescriba el estado original del ciudadano (para cambiar su categoría o para rechazarlo por broma), se guarda un registro de su estado original en esta tabla.

## 3. Servicios y Controladores Creados / Modificados

### A. Servicio de IA (`src/services/ai.service.js`)
Se instaló la librería `@google/generative-ai`.
Este archivo posee la función principal `analizarReporte(reporte, imagenesUrls)`:
- Recibe todo el objeto original en JSON del reporte (con su categoría base, áreas y usuario).
- Recibe las imágenes y las procesa.
- Envía el *Prompt* (instrucciones maestras) pidiendo a la IA que devuelva un objeto con la estructura `es_valido`, `prioridad` y `categoria_sugerida`.

### B. Modificación en Rutas (`src/routes/reportes.routes.js`)
Se expusieron dos nuevos endpoints:
- **Ruta:** `POST /reportes/:id/analizar`
- **Permisos:** Protegido mediante `requireRole(['funcionario', 'admin'])`.
- El ciudadano o "vecino" no tiene acceso para activar la IA en su propio reporte de manera manual.

- **Ruta:** `GET /reportes/historial-ia`
- **Permisos:** Protegido mediante `requireRole(['admin'])`.
- Permite consultar el historial de los reportes originales vs cómo quedaron tras ser cambiados por la Inteligencia Artificial. Exclusivo para administradores.

### C. Controlador Principal (`src/controllers/reportes.controller.js`)
El método `analizarReporteConIA` es el núcleo de este flujo. Sigue los siguientes pasos en orden:
1. **Extracción:** Saca de la BD el reporte completo, haciendo JOIN con categorías, áreas y leyendo las URLs de la tabla `adjuntos`.
2. **Evaluación:** Envía todo a `ai.service.js` para recibir el veredicto en formato JSON.
3. **Decisiones Automáticas (Reglas de Negocio):**
   - **Caso Inválido:** Si Gemini dice que `es_valido: false`, el backend busca el ID de estado `'rechazado'` para aplicarlo de inmediato.
   - **Caso Cambio de Categoría:** Si Gemini devuelve un nombre de categoría diferente al actual, el backend hace una búsqueda rápida (`ilike`) para encontrar esa categoría en el catálogo de tu BD.
4. **Respaldar Historial:** Si las decisiones del paso anterior desencadenan un cambio real en el ID de la Categoría o en el ID de Estado, el sistema inserta una fila en `reportes_historial` guardando cómo estaban antes.
5. **Actualizar el Original:** Sobrescribe la tabla `reportes` directamente con la nueva categoría y/o el estado rechazado.
6. **Guardar el Análisis Completo:** Finalmente, guarda un dictamen completo (el veredicto de `es_valido`, `prioridad`, etc) haciendo un `upsert` en la tabla `analisis_ia`.

## 4. Requisitos para Funcionamiento
- Agregar la variable `GEMINI_API_KEY="tu-api-key"` en el archivo `.env`.
- Ejecutar el archivo SQL (`ejecutar_en_supabase.sql`) para tener listas las dos nuevas tablas (`analisis_ia` y `reportes_historial`).
