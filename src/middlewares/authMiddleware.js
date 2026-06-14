const jwt = require('jsonwebtoken');
const { supabase } = require('../config/supabase');

const requireAuth = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            return res.status(401).json({ error: 'No autorizado, falta token' });
        }

        const { data: { user }, error } = await supabase.auth.getUser(token);

        if (error || !user) {
            return res.status(401).json({ error: 'Token invalido o expirado' });
        }

        req.user = user;
        
        // Obtener rol del usuario desde la tabla usuarios
        const { data: userData, error: userError } = await supabase
            .from('usuarios')
            .select('rol')
            .eq('id_usuario', user.id)
            .single();
            
        if (!userError && userData) {
            req.user.rol = userData.rol;
        }

        next();
    } catch (error) {
        res.status(500).json({ error: 'Error interno de autenticacion' });
    }
};

const requireRole = (roles) => {
    return (req, res, next) => {
        if (!req.user || !roles.includes(req.user.rol)) {
            return res.status(403).json({ error: 'Prohibido, no tienes los permisos necesarios' });
        }
        next();
    };
};

/**
 * Middleware para verificar si un usuario ciudadano está bloqueado.
 * 
 * - Solo afecta a usuarios con rol 'ciudadano'
 * - Verifica bloqueos activos en la tabla bloqueos_usuario
 * - Auto-expira bloqueos temporales que ya pasaron
 * - Si está bloqueado, retorna 403 con los datos del bloqueo
 * 
 * Uso: router.post('/', requireAuth, checkBloqueo, createReporte);
 */
const checkBloqueo = async (req, res, next) => {
    try {
        // Solo verificar ciudadanos (funcionarios y admins están exentos)
        if (!req.user || req.user.rol !== 'ciudadano') {
            return next();
        }

        const usuario_id = req.user.id;

        // Buscar bloqueo activo
        const { data: bloqueo, error } = await supabase
            .from('bloqueos_usuario')
            .select('*')
            .eq('usuario_id', usuario_id)
            .eq('activo', true)
            .maybeSingle();

        if (error) {
            console.error('Error al verificar bloqueo:', error.message);
            return next(); // En caso de error, dejamos pasar para no bloquear injustamente
        }

        if (!bloqueo) {
            return next(); // No tiene bloqueo activo
        }

        // Verificar si el bloqueo temporal ya expiró
        if (bloqueo.fecha_desbloqueo && new Date(bloqueo.fecha_desbloqueo) <= new Date()) {
            // Expiró → auto-desbloquear
            await supabase
                .from('bloqueos_usuario')
                .update({
                    activo: false,
                    fecha_desbloqueado: new Date().toISOString(),
                    notas_admin: 'Desbloqueado automáticamente por expiración del tiempo'
                })
                .eq('id_bloqueo', bloqueo.id_bloqueo);

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

            console.log(`✅ Bloqueo expirado para usuario ${usuario_id}, acceso restaurado`);
            return next(); // Bloqueo expirado, dejar pasar
        }

        // El usuario ESTÁ bloqueado activamente
        // Obtener configuración para el teléfono y mensaje
        const { data: config } = await supabase
            .from('configuracion_bloqueos')
            .select('telefono_contacto, mensaje_bloqueo')
            .eq('id', 1)
            .single();

        return res.status(403).json({
            error: 'Cuenta bloqueada',
            bloqueado: true,
            motivo: bloqueo.motivo,
            tipo: bloqueo.tipo,
            fecha_bloqueo: bloqueo.fecha_bloqueo,
            fecha_desbloqueo: bloqueo.fecha_desbloqueo,
            strikes_acumulados: bloqueo.strikes_acumulados,
            telefono_contacto: config?.telefono_contacto || '222-0000',
            mensaje_bloqueo: config?.mensaje_bloqueo || 'Su cuenta ha sido suspendida.'
        });
    } catch (error) {
        console.error('Error en checkBloqueo:', error.message);
        next(); // En caso de error, dejamos pasar
    }
};

module.exports = { requireAuth, requireRole, checkBloqueo };
