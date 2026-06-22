const { supabase } = require('../config/supabase');

// ─────────────────────────────────────────────
// Obtener usuarios bloqueados actualmente
// ─────────────────────────────────────────────
const getUsuariosBloqueados = async (req, res, next) => {
    try {
        const { data: bloqueos, error: bloqueosError } = await supabase
            .from('bloqueos_usuario')
            .select('*')
            .eq('activo', true)
            .order('fecha_bloqueo', { ascending: false });

        if (bloqueosError) throw bloqueosError;

        if (!bloqueos || bloqueos.length === 0) {
            return res.json([]);
        }

        // Obtener los datos de los usuarios correspondientes
        const userIds = bloqueos.map(b => b.usuario_id);
        const { data: users, error: usersError } = await supabase
            .from('usuarios')
            .select('id_usuario, nombre, correo, telefono, rol')
            .in('id_usuario', userIds);

        if (usersError) throw usersError;

        // Obtener los reportes correspondientes
        const reportIds = bloqueos.map(b => b.reporte_id).filter(id => id != null);
        let reports = [];
        if (reportIds.length > 0) {
            const { data: reps, error: repsError } = await supabase
                .from('reportes')
                .select('id_reporte, descripcion, fecha_creacion')
                .in('id_reporte', reportIds);
            if (repsError) throw repsError;
            reports = reps || [];
        }

        const ahora = new Date();
        const bloqueosActivos = [];

        for (const bloqueo of bloqueos) {
            if (bloqueo.fecha_desbloqueo && new Date(bloqueo.fecha_desbloqueo) <= ahora) {
                // Expiró → desactivar
                await _autoDesbloquear(bloqueo.id_bloqueo, bloqueo.usuario_id);
            } else {
                const user = (users || []).find(u => u.id_usuario === bloqueo.usuario_id);
                const report = reports.find(r => r.id_reporte === bloqueo.reporte_id);

                bloqueosActivos.push({
                    ...bloqueo,
                    usuario: user || null,
                    reporte: report || null
                });
            }
        }

        res.json(bloqueosActivos);
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Historial de bloqueos de un usuario específico
// ─────────────────────────────────────────────
const getHistorialBloqueos = async (req, res, next) => {
    try {
        const { usuario_id } = req.params;

        const { data: bloqueos, error: errorBloqueos } = await supabase
            .from('bloqueos_usuario')
            .select('*')
            .eq('usuario_id', usuario_id)
            .order('fecha_bloqueo', { ascending: false });

        if (errorBloqueos) throw errorBloqueos;

        if (!bloqueos || bloqueos.length === 0) {
            return res.json([]);
        }

        // Obtener usuarios administradores que realizaron los desbloqueos
        const adminIds = bloqueos.map(b => b.desbloqueado_por).filter(id => id != null);
        let admins = [];
        if (adminIds.length > 0) {
            const { data: adm, error: admError } = await supabase
                .from('usuarios')
                .select('id_usuario, nombre, correo')
                .in('id_usuario', adminIds);
            if (admError) throw admError;
            admins = adm || [];
        }

        // Obtener los reportes correspondientes
        const reportIds = bloqueos.map(b => b.reporte_id).filter(id => id != null);
        let reports = [];
        if (reportIds.length > 0) {
            const { data: reps, error: repsError } = await supabase
                .from('reportes')
                .select('id_reporte, descripcion')
                .in('id_reporte', reportIds);
            if (repsError) throw repsError;
            reports = reps || [];
        }

        const data = bloqueos.map(b => {
            const admin = admins.find(a => a.id_usuario === b.desbloqueado_por);
            const report = reports.find(r => r.id_reporte === b.reporte_id);
            return {
                ...b,
                reporte: report || null,
                admin_desbloqueo: admin || null
            };
        });

        res.json(data);
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Bloquear un usuario manualmente (admin)
// ─────────────────────────────────────────────
const bloquearUsuario = async (req, res, next) => {
    try {
        const { usuario_id } = req.params;
        const { motivo, duracion_horas, reporte_id, notas_admin } = req.body;
        const admin_id = req.user.id;

        if (!motivo) {
            return res.status(400).json({ error: 'El motivo es obligatorio' });
        }

        // Verificar que el usuario existe y es ciudadano
        const { data: usuario, error: userError } = await supabase
            .from('usuarios')
            .select('id_usuario, nombre, rol')
            .eq('id_usuario', usuario_id)
            .single();

        if (userError) throw userError;
        if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });

        if (usuario.rol !== 'ciudadano') {
            return res.status(400).json({ error: 'Solo se puede bloquear a ciudadanos' });
        }

        // Verificar si ya tiene un bloqueo activo
        const { data: bloqueoExistente } = await supabase
            .from('bloqueos_usuario')
            .select('id_bloqueo')
            .eq('usuario_id', usuario_id)
            .eq('activo', true)
            .maybeSingle();

        if (bloqueoExistente) {
            return res.status(409).json({ error: 'El usuario ya tiene un bloqueo activo' });
        }

        // Contar strikes previos (acumulativos)
        const { count: strikesAnteriores } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('usuario_id', usuario_id);

        const strikesActuales = (strikesAnteriores || 0) + 1;

        // Calcular fecha de desbloqueo
        let fecha_desbloqueo = null;
        if (duracion_horas && duracion_horas > 0) {
            fecha_desbloqueo = new Date();
            fecha_desbloqueo.setHours(fecha_desbloqueo.getHours() + duracion_horas);
        }

        // Insertar bloqueo
        const { data: bloqueo, error: bloqueoError } = await supabase
            .from('bloqueos_usuario')
            .insert([{
                usuario_id,
                reporte_id: reporte_id || null,
                motivo,
                tipo: 'manual',
                strikes_acumulados: strikesActuales,
                fecha_desbloqueo,
                notas_admin: notas_admin || null
            }])
            .select()
            .single();

        if (bloqueoError) throw bloqueoError;

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

        // Registrar en seguimiento (si hay reporte asociado)
        if (reporte_id) {
            await supabase.from('seguimiento').insert([{
                reporte_id,
                usuario_id: admin_id,
                tipo_evento: 'bloqueo_usuario',
                descripcion: `Usuario ${usuario.nombre} bloqueado manualmente. Motivo: ${motivo}`,
                estado_nuevo_id: estadoSuspendido?.id_estado
            }]);
        }

        res.status(201).json({
            message: `Usuario ${usuario.nombre} bloqueado correctamente`,
            bloqueo,
            strikes_acumulados: strikesActuales
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Desbloquear un usuario manualmente (admin)
// ─────────────────────────────────────────────
const desbloquearUsuario = async (req, res, next) => {
    try {
        const { usuario_id } = req.params;
        const { notas_admin } = req.body;
        const admin_id = req.user.id;

        // Buscar bloqueo activo
        const { data: bloqueo, error: bloqueoError } = await supabase
            .from('bloqueos_usuario')
            .select('*')
            .eq('usuario_id', usuario_id)
            .eq('activo', true)
            .maybeSingle();

        if (bloqueoError) throw bloqueoError;
        if (!bloqueo) {
            return res.status(404).json({ error: 'No se encontró un bloqueo activo para este usuario' });
        }

        // Desactivar el bloqueo
        const { error: updateError } = await supabase
            .from('bloqueos_usuario')
            .update({
                activo: false,
                desbloqueado_por: admin_id,
                fecha_desbloqueado: new Date().toISOString(),
                notas_admin: notas_admin || bloqueo.notas_admin
            })
            .eq('id_bloqueo', bloqueo.id_bloqueo);

        if (updateError) throw updateError;

        // Restaurar estado del usuario a 'activo'
        const { data: estadoActivo } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'usuario')
            .eq('codigo', 'activo')
            .single();

        if (estadoActivo) {
            await supabase
                .from('usuarios')
                .update({ estado_id: estadoActivo.id_estado })
                .eq('id_usuario', usuario_id);
        }

        // Registrar en seguimiento si hay reporte
        if (bloqueo.reporte_id) {
            await supabase.from('seguimiento').insert([{
                reporte_id: bloqueo.reporte_id,
                usuario_id: admin_id,
                tipo_evento: 'desbloqueo_usuario',
                descripcion: `Usuario desbloqueado manualmente por admin.${notas_admin ? ' Notas: ' + notas_admin : ''}`,
                estado_nuevo_id: estadoActivo?.id_estado
            }]);
        }

        res.json({ message: 'Usuario desbloqueado correctamente' });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Verificar si el usuario actual está bloqueado
// ─────────────────────────────────────────────
const verificarBloqueo = async (req, res, next) => {
    try {
        const usuario_id = req.user.id;

        const { data: bloqueo, error } = await supabase
            .from('bloqueos_usuario')
            .select('*')
            .eq('usuario_id', usuario_id)
            .eq('activo', true)
            .maybeSingle();

        if (error) throw error;

        if (!bloqueo) {
            return res.json({ bloqueado: false });
        }

        // Verificar si expiró
        if (bloqueo.fecha_desbloqueo && new Date(bloqueo.fecha_desbloqueo) <= new Date()) {
            await _autoDesbloquear(bloqueo.id_bloqueo, usuario_id);
            return res.json({ bloqueado: false });
        }

        // Obtener configuración para el teléfono y mensaje
        const { data: config } = await supabase
            .from('configuracion_bloqueos')
            .select('telefono_contacto, mensaje_bloqueo')
            .eq('id', 1)
            .single();

        res.json({
            bloqueado: true,
            motivo: bloqueo.motivo,
            tipo: bloqueo.tipo,
            fecha_bloqueo: bloqueo.fecha_bloqueo,
            fecha_desbloqueo: bloqueo.fecha_desbloqueo,
            strikes_acumulados: bloqueo.strikes_acumulados,
            telefono_contacto: config?.telefono_contacto || '222-0000',
            mensaje_bloqueo: config?.mensaje_bloqueo || 'Su cuenta ha sido suspendida.'
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Obtener configuración del sistema de bloqueos
// ─────────────────────────────────────────────
const getConfiguracion = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('configuracion_bloqueos')
            .select('*')
            .eq('id', 1)
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Actualizar configuración del sistema de bloqueos
// ─────────────────────────────────────────────
const updateConfiguracion = async (req, res, next) => {
    try {
        const {
            auto_bloqueo_ia,
            strikes_para_bloqueo,
            duracion_primer_strike_horas,
            duracion_segundo_strike_horas,
            duracion_tercer_strike_horas,
            telefono_contacto,
            mensaje_bloqueo
        } = req.body;

        const updates = {};
        if (auto_bloqueo_ia !== undefined) updates.auto_bloqueo_ia = auto_bloqueo_ia;
        if (strikes_para_bloqueo !== undefined) updates.strikes_para_bloqueo = strikes_para_bloqueo;
        if (duracion_primer_strike_horas !== undefined) updates.duracion_primer_strike_horas = duracion_primer_strike_horas;
        if (duracion_segundo_strike_horas !== undefined) updates.duracion_segundo_strike_horas = duracion_segundo_strike_horas;
        if (duracion_tercer_strike_horas !== undefined) updates.duracion_tercer_strike_horas = duracion_tercer_strike_horas;
        if (telefono_contacto !== undefined) updates.telefono_contacto = telefono_contacto;
        if (mensaje_bloqueo !== undefined) updates.mensaje_bloqueo = mensaje_bloqueo;
        updates.updated_at = new Date().toISOString();

        const { data, error } = await supabase
            .from('configuracion_bloqueos')
            .update(updates)
            .eq('id', 1)
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Estadísticas de bloqueos (admin)
// ─────────────────────────────────────────────
const getEstadisticas = async (req, res, next) => {
    try {
        // Total de bloqueos activos
        const { count: totalActivos } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('activo', true);

        // Total de bloqueos históricos
        const { count: totalHistoricos } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true });

        // Bloqueos este mes
        const inicioMes = new Date();
        inicioMes.setDate(1);
        inicioMes.setHours(0, 0, 0, 0);

        const { count: bloqueosMes } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .gte('fecha_bloqueo', inicioMes.toISOString());

        // Bloqueos por tipo
        const { count: bloqueosIA } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('tipo', 'automatico_ia');

        const { count: bloqueosManuales } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('tipo', 'manual');

        res.json({
            total_activos: totalActivos || 0,
            total_historicos: totalHistoricos || 0,
            bloqueos_mes: bloqueosMes || 0,
            bloqueos_ia: bloqueosIA || 0,
            bloqueos_manuales: bloqueosManuales || 0
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Función interna: auto-desbloquear por expiración
// ─────────────────────────────────────────────
const _autoDesbloquear = async (id_bloqueo, usuario_id) => {
    try {
        await supabase
            .from('bloqueos_usuario')
            .update({
                activo: false,
                fecha_desbloqueado: new Date().toISOString(),
                notas_admin: 'Desbloqueado automáticamente por expiración del tiempo'
            })
            .eq('id_bloqueo', id_bloqueo);

        // Restaurar estado a 'activo'
        const { data: estadoActivo } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'usuario')
            .eq('codigo', 'activo')
            .single();

        if (estadoActivo) {
            await supabase
                .from('usuarios')
                .update({ estado_id: estadoActivo.id_estado })
                .eq('id_usuario', usuario_id);
        }

        console.log(`✅ Usuario ${usuario_id} desbloqueado automáticamente por expiración`);
    } catch (err) {
        console.error('Error al auto-desbloquear:', err.message);
    }
};

module.exports = {
    getUsuariosBloqueados,
    getHistorialBloqueos,
    bloquearUsuario,
    desbloquearUsuario,
    verificarBloqueo,
    getConfiguracion,
    updateConfiguracion,
    getEstadisticas
};
