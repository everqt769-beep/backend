const { supabase } = require('../config/supabase');
const { analizarReporte } = require('../services/ai.service');

// Obtener todos los reportes
const getReportes = async (req, res, next) => {
    try {
        let query = supabase
            .from('reportes')
            .select(`
                *,
                usuarios(nombre, correo),
                categorias(nombre, areas(nombre)),
                estados(nombre, color),
                analisis_ia(
                    es_valido,
                    prioridad,
                    categoria_sugerida,
                    justificacion,
                    fecha_analisis
                )
            `);

        if (req.query.usuario_id) {
            const usuarioId = req.query.usuario_id.replace('eq.', '');
            query = query.eq('usuario_id', usuarioId);
        }

        const { data, error } = await query
            .order('fecha_creacion', { ascending: false });

        if (error) throw error;

        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener un reporte por ID (consulta en dos pasos para incluir analisis_ia)
const getReporteById = async (req, res, next) => {
  try {
    const { id } = req.params;

    // 1) Traer el reporte con sus relaciones que sí existen
    const { data: reporte, error: reporteError } = await supabase
      .from('reportes')
      .select(`
        *,
        usuarios(nombre, correo),
        categorias(nombre, areas(*)),
        estados(*),
        adjuntos(*),
        comentarios(*, usuarios(nombre, rol)),
        seguimiento(*, estados(*), usuarios(nombre))
      `)
      .eq('id_reporte', id)
      .single();

    if (reporteError) {
      // Manejo explícito de "no encontrado"
      if (reporteError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      throw reporteError;
    }

    // 2) Traer el análisis IA por separado (si existe)
    const { data: analisisIA, error: analisisError } = await supabase
      .from('analisis_ia')
      .select('*')
      .eq('reporte_id', id)
      .single();

    // Si analisisError existe y no es "no encontrado", loguearlo pero no bloquear la respuesta
    if (analisisError && analisisError.code !== 'PGRST116') {
      console.warn('Advertencia al obtener analisis_ia:', analisisError.message);
    }

    // Unir y devolver
    res.json({ ...reporte, analisis_ia: analisisIA || null });
  } catch (err) {
    console.error("Error en getReporteById:", err.message || err);
    res.status(500).json({ error: "Error interno al obtener el reporte" });
  }
};



// Crear un nuevo reporte
const createReporte = async (req, res, next) => {
    try {
        const { categoria_id, descripcion, latitud, longitud, direccion } = req.body;
        const usuario_id = req.user.id;

        if (!descripcion) {
            return res.status(400).json({ error: 'La descripción es obligatoria' });
        }

        // Obtener id del estado 'pendiente' para reporte
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'reporte')
            .eq('codigo', 'pendiente')
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('reportes')
            .insert([{
                usuario_id,
                categoria_id,
                descripcion,
                latitud,
                longitud,
                direccion,
                estado_id: estado.id_estado
            }])
            .select()
            .single();

        if (error) throw error;

        // Registrar en seguimiento
        await supabase.from('seguimiento').insert([{
            reporte_id: data.id_reporte,
            usuario_id,
            tipo_evento: 'creacion',
            descripcion: 'Reporte creado por el ciudadano',
            estado_nuevo_id: estado.id_estado
        }]);

        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar el estado de un reporte (funcionario/admin)
const updateEstadoReporte = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { estado_codigo, descripcion_seguimiento } = req.body;
        const usuario_id = req.user.id;

        // Obtener ID del nuevo estado
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'reporte')
            .eq('codigo', estado_codigo)
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('reportes')
            .update({ estado_id: estado.id_estado })
            .eq('id_reporte', id)
            .select()
            .single();

        if (error) throw error;

        // Registrar en seguimiento
        await supabase.from('seguimiento').insert([{
            reporte_id: id,
            usuario_id,
            tipo_evento: 'cambio_estado',
            descripcion: descripcion_seguimiento || `Estado cambiado a ${estado_codigo}`,
            estado_nuevo_id: estado.id_estado
        }]);

        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar un reporte completo (datos del reporte, no solo estado)
const updateReporte = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { categoria_id, descripcion, latitud, longitud, direccion } = req.body;

        const { data, error } = await supabase
            .from('reportes')
            .update({ categoria_id, descripcion, latitud, longitud, direccion })
            .eq('id_reporte', id)
            .select(`
                *,
                usuarios(nombre, correo),
                categorias(nombre, areas(nombre)),
                estados(nombre, color)
            `)
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Reporte no encontrado' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Eliminar un reporte
const deleteReporte = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('reportes')
            .delete()
            .eq('id_reporte', id);

        if (error) throw error;
        res.json({ message: 'Reporte eliminado correctamente' });
    } catch (err) {
        next(err);
    }
};

// Analizar un reporte usando IA (Gemini) — CON AUTO-BLOQUEO
const analizarReporteConIA = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Obtener el reporte completo con sus relaciones
        const { data: reporte, error: reporteError } = await supabase
            .from('reportes')
            .select(`
                *,
                categorias(nombre, prioridad_base, areas(nombre)),
                usuarios(id_usuario, nombre, rol),
                adjuntos(url)
            `)
            .eq('id_reporte', id)
            .single();

        if (reporteError) throw reporteError;
        if (!reporte) return res.status(404).json({ error: 'Reporte no encontrado' });

        // Obtener TODAS las categorías existentes para pasárselas a la IA
        const { data: categoriasExistentes } = await supabase
            .from('categorias')
            .select('id_categoria, nombre, prioridad_base, areas(nombre)');

        // Obtener historial de strikes del usuario (para enriquecer el prompt)
        let strikesUsuario = 0;
        if (reporte.usuarios?.rol === 'ciudadano') {
            const { count } = await supabase
                .from('bloqueos_usuario')
                .select('*', { count: 'exact', head: true })
                .eq('usuario_id', reporte.usuario_id);
            strikesUsuario = count || 0;
        }

        // Extraer URLs de los adjuntos para pasárselos a la IA
        const imagenesUrls = reporte.adjuntos ? reporte.adjuntos.map(adj => adj.url) : [];

        // Llamar a Gemini (ahora le pasamos las categorías existentes y los strikes)
        const analisis = await analizarReporte(reporte, imagenesUrls, categoriasExistentes || [], strikesUsuario);

        let nuevo_estado_id = reporte.estado_id;
        let nueva_categoria_id = reporte.categoria_id;
        let bloqueoRealizado = null;

        // CASO 1: Si la IA dice que es broma/falso → rechazar
        if (analisis.es_valido === false) {
            const { data: estadoData } = await supabase
                .from('estados')
                .select('id_estado')
                .eq('entidad', 'reporte')
                .eq('codigo', 'rechazado')
                .single();
            if (estadoData) nuevo_estado_id = estadoData.id_estado;

            // ── AUTO-BLOQUEO POR IA ──
            // Solo si el dueño del reporte es ciudadano
            if (reporte.usuarios?.rol === 'ciudadano') {
                bloqueoRealizado = await _intentarAutoBloqueo(
                    reporte.usuario_id,
                    reporte.usuarios.nombre,
                    id,
                    analisis.justificacion
                );
            }

        // CASO 2: Si la IA sugiere una categoría diferente
        } else if (analisis.categoria_sugerida && analisis.categoria_sugerida !== reporte.categorias?.nombre) {

            // Primero buscamos si ya existe esa categoría en la BD
            const { data: catData } = await supabase
                .from('categorias')
                .select('id_categoria')
                .ilike('nombre', analisis.categoria_sugerida)
                .limit(1)
                .single();

            if (catData) {
                // La categoría existe, usamos su ID
                nueva_categoria_id = catData.id_categoria;
            } else {
                // La categoría NO existe → la creamos automáticamente
                // Mapeamos la prioridad texto a número: alta=1, media=2, baja=3
                const mapPrioridad = { 'alta': 1, 'media': 2, 'baja': 3 };
                const prioridadNum = mapPrioridad[analisis.prioridad] || 2;

                const { data: nuevaCat, error: catError } = await supabase
                    .from('categorias')
                    .insert([{
                        nombre: analisis.categoria_sugerida,
                        descripcion: 'Categoría creada automáticamente por la IA',
                        prioridad_base: prioridadNum
                    }])
                    .select()
                    .single();

                if (!catError && nuevaCat) {
                    nueva_categoria_id = nuevaCat.id_categoria;
                    console.log(`✅ Nueva categoría creada por IA: "${analisis.categoria_sugerida}"`);
                } else {
                    console.warn("⚠️ No se pudo crear la categoría sugerida por la IA:", catError?.message);
                }
            }
        }

        // Si hubo algún cambio, guardamos en historial y actualizamos el reporte original
        if (nuevo_estado_id !== reporte.estado_id || nueva_categoria_id !== reporte.categoria_id) {

            // 1. Guardar historial (el estado original ANTES de que la IA lo modifique)
            const { error: histError } = await supabase.from('reportes_historial').insert([{
                reporte_id: id,
                categoria_id_original: reporte.categoria_id,
                estado_id_original: reporte.estado_id
            }]);

            if (histError) console.error("Error al guardar historial:", histError.message);

            // 2. Actualizar reporte original directamente
            const { error: updateError } = await supabase.from('reportes')
                .update({
                    categoria_id: nueva_categoria_id,
                    estado_id: nuevo_estado_id
                })
                .eq('id_reporte', id);

            if (updateError) throw updateError;

            // Actualizar el objeto reporte local para la respuesta
            reporte.categoria_id = nueva_categoria_id;
            reporte.estado_id = nuevo_estado_id;
        }

        // Guardar el análisis de IA en la tabla analisis_ia
        const { data, error: insertError } = await supabase
            .from('analisis_ia')
            .upsert({
                reporte_id: id,
                es_valido: analisis.es_valido,
                prioridad: analisis.prioridad,
                categoria_sugerida: analisis.categoria_sugerida,
                justificacion: analisis.justificacion || "Procesado por IA"
            }, { onConflict: 'reporte_id' })
            .select()
            .single();

        if (insertError) {
            console.warn("No se pudo guardar en 'analisis_ia': ", insertError.message);
            return res.json({
                ...reporte,
                analisis_ia: analisis,
                bloqueo: bloqueoRealizado,
                warning: "Análisis exitoso pero no se pudo persistir en la tabla analisis_ia."
            });
        }

        res.json({ ...reporte, analisis_ia: data, bloqueo: bloqueoRealizado });

    } catch (err) {
        console.error("🔴 ERROR CRÍTICO EN ANALIZAR_REPORTE:", err);

        res.status(500).json({
            error: "Error interno en el servidor al analizar con IA",
            message: err.message
        });
    }
};

/**
 * Función interna: intentar auto-bloqueo por IA
 * Verifica la configuración y aplica el bloqueo si corresponde
 */
const _intentarAutoBloqueo = async (usuario_id, nombre_usuario, reporte_id, justificacion) => {
    try {
        // Consultar configuración
        const { data: config } = await supabase
            .from('configuracion_bloqueos')
            .select('*')
            .eq('id', 1)
            .single();

        if (!config || !config.auto_bloqueo_ia) {
            console.log('ℹ️ Auto-bloqueo por IA desactivado');
            return null;
        }

        // Contar strikes previos del usuario (acumulativos)
        const { count: strikesAnteriores } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('usuario_id', usuario_id);

        const strikesActuales = (strikesAnteriores || 0) + 1;

        // Verificar si ya tiene un bloqueo activo
        const { data: bloqueoExistente } = await supabase
            .from('bloqueos_usuario')
            .select('id_bloqueo')
            .eq('usuario_id', usuario_id)
            .eq('activo', true)
            .maybeSingle();

        if (bloqueoExistente) {
            console.log(`ℹ️ Usuario ${usuario_id} ya tiene un bloqueo activo, no se aplica otro`);
            return { ya_bloqueado: true, strikes: strikesActuales };
        }

        // Calcular duración del bloqueo según strikes
        let duracion_horas = 0;
        if (strikesActuales === 1) {
            duracion_horas = config.duracion_primer_strike_horas;
        } else if (strikesActuales === 2) {
            duracion_horas = config.duracion_segundo_strike_horas;
        } else {
            duracion_horas = config.duracion_tercer_strike_horas; // 0 = permanente
        }

        // Calcular fecha de desbloqueo
        let fecha_desbloqueo = null;
        if (duracion_horas > 0) {
            fecha_desbloqueo = new Date();
            fecha_desbloqueo.setHours(fecha_desbloqueo.getHours() + duracion_horas);
        }

        // Insertar bloqueo
        const { data: bloqueo, error: bloqueoError } = await supabase
            .from('bloqueos_usuario')
            .insert([{
                usuario_id,
                reporte_id,
                motivo: `Bloqueo automático por IA: ${justificacion || 'Reporte detectado como falso'}`,
                tipo: 'automatico_ia',
                strikes_acumulados: strikesActuales,
                fecha_desbloqueo
            }])
            .select()
            .single();

        if (bloqueoError) {
            console.error('Error al crear bloqueo automático:', bloqueoError.message);
            return null;
        }

        // Cambiar estado del usuario a 'suspendido'
        const { data: estadoSuspendido } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'usuario')
            .eq('codigo', 'suspendido')
            .single();

        if (estadoSuspendido) {
            await supabase
                .from('usuarios')
                .update({ estado_id: estadoSuspendido.id_estado })
                .eq('id_usuario', usuario_id);
        }

        // Registrar en seguimiento
        await supabase.from('seguimiento').insert([{
            reporte_id,
            usuario_id,
            tipo_evento: 'bloqueo_automatico_ia',
            descripcion: `Usuario ${nombre_usuario} bloqueado automáticamente por la IA (Strike #${strikesActuales}). ${duracion_horas > 0 ? `Duración: ${duracion_horas}h` : 'Permanente'}`,
            estado_nuevo_id: estadoSuspendido?.id_estado
        }]);

        console.log(`🚫 Usuario ${nombre_usuario} (${usuario_id}) bloqueado automáticamente por IA — Strike #${strikesActuales}`);

        return {
            bloqueado: true,
            strikes: strikesActuales,
            duracion_horas,
            permanente: duracion_horas === 0,
            fecha_desbloqueo
        };
    } catch (err) {
        console.error('Error en auto-bloqueo:', err.message);
        return null;
    }
};

// Obtener el historial de reportes modificados por la IA (solo admin)
const getHistorialIA = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('reportes_historial')
            .select(`
                *,
                reporte_actual:reportes(
                    *,
                    categorias(nombre),
                    estados(nombre, color),
                    analisis_ia(es_valido, prioridad, categoria_sugerida, justificacion, fecha_analisis)
                ),
                categoria_original:categorias(nombre),
                estado_original:estados(nombre, color)
            `)
            .order('fecha_modificacion', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getReportes,
    getReporteById,
    createReporte,
    updateEstadoReporte,
    updateReporte,
    deleteReporte,
    analizarReporteConIA,
    getHistorialIA
};
