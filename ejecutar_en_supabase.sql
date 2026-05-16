-- =====================================================================
-- COMANDOS SQL PARA LA INTEGRACIÓN DE INTELIGENCIA ARTIFICIAL (GEMINI)
-- =====================================================================
-- Ejecuta esto en el Editor SQL de tu panel de Supabase.
ALTER TABLE reportes ADD COLUMN ia_analisis JSONB;

-- 1. TABLA ANALISIS_IA
-- Guarda de forma separada todo el veredicto y evaluación que genera la Inteligencia Artificial.
CREATE TABLE analisis_ia (
    id_analisis UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporte_id UUID REFERENCES reportes(id_reporte) ON DELETE CASCADE UNIQUE,
    es_valido BOOLEAN NOT NULL,
    prioridad TEXT CHECK (prioridad IN ('alta', 'media', 'baja')),
    categoria_sugerida TEXT,
    justificacion TEXT,
    fecha_analisis TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABLA REPORTES_HISTORIAL
-- Guarda el estado original de la denuncia hecha por el ciudadano ANTES de que la IA le cambie el estado (ej. a rechazado) o le modifique la categoría sugerida.
CREATE TABLE reportes_historial (
    id_historial UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporte_id UUID REFERENCES reportes(id_reporte) ON DELETE CASCADE,
    categoria_id_original UUID REFERENCES categorias(id_categoria),
    estado_id_original UUID REFERENCES estados(id_estado),
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW()
);
