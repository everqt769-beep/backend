-- =====================================================================
-- MIGRACIÓN: SISTEMA DE BLOQUEOS POR REPORTES FALSOS
-- =====================================================================
-- Ejecuta esto en el Editor SQL de tu panel de Supabase.

-- 1. TABLA bloqueos_usuario
-- Registra cada bloqueo/desbloqueo de usuarios (solo ciudadanos)
CREATE TABLE bloqueos_usuario (
    id_bloqueo UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    reporte_id UUID REFERENCES reportes(id_reporte) ON DELETE SET NULL,
    motivo TEXT NOT NULL,
    tipo TEXT NOT NULL CHECK (tipo IN ('manual', 'automatico_ia')),
    strikes_acumulados INT NOT NULL DEFAULT 1,
    fecha_bloqueo TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_desbloqueo TIMESTAMPTZ,        -- NULL = permanente
    desbloqueado_por UUID REFERENCES usuarios(id_usuario),
    fecha_desbloqueado TIMESTAMPTZ,
    activo BOOLEAN NOT NULL DEFAULT true,
    notas_admin TEXT
);

-- 2. TABLA configuracion_bloqueos (singleton, solo 1 fila)
-- Configuración global del sistema de bloqueos gestionada por el admin
CREATE TABLE configuracion_bloqueos (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    auto_bloqueo_ia BOOLEAN NOT NULL DEFAULT false,
    strikes_para_bloqueo INT NOT NULL DEFAULT 1,
    duracion_primer_strike_horas INT NOT NULL DEFAULT 24,
    duracion_segundo_strike_horas INT NOT NULL DEFAULT 72,
    duracion_tercer_strike_horas INT NOT NULL DEFAULT 0, -- 0 = permanente
    telefono_contacto TEXT NOT NULL DEFAULT '222-0000',
    mensaje_bloqueo TEXT NOT NULL DEFAULT 'Su cuenta ha sido suspendida temporalmente por enviar reportes falsos. Contacte al administrador para más información.',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar configuración inicial por defecto
INSERT INTO configuracion_bloqueos DEFAULT VALUES;

-- 3. Nuevo estado para usuarios: 'suspendido'
INSERT INTO estados (entidad, codigo, nombre, color, descripcion) VALUES
('usuario', 'suspendido', 'Suspendido', '#FF6B35', 'Usuario suspendido temporalmente por reportes falsos');

-- 4. Índices para performance
CREATE INDEX idx_bloqueos_usuario_id ON bloqueos_usuario(usuario_id);
CREATE INDEX idx_bloqueos_activo ON bloqueos_usuario(activo) WHERE activo = true;
CREATE INDEX idx_bloqueos_fecha_desbloqueo ON bloqueos_usuario(fecha_desbloqueo) WHERE activo = true;
