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

module.exports = { requireAuth, requireRole };
