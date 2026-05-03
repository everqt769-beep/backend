const { supabase, supabaseAdmin } = require('../config/supabase');

// Obtener perfil del usuario autenticado
const getPerfil = async (req, res, next) => {
    try {
        const { id } = req.user;
        const { data, error } = await supabase.from('usuarios').select('*, areas(*), estados(*)').eq('id_usuario', id).maybeSingle();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar perfil del usuario autenticado
const updatePerfil = async (req, res, next) => {
    try {
        const { id } = req.user;
        const updates = req.body;
        
        // Evitar cambios de rol o estado desde el cliente regular
        delete updates.rol;
        delete updates.estado_id;
        delete updates.id_usuario;

        const { data, error } = await supabase
            .from('usuarios')
            .update(updates)
            .eq('id_usuario', id)
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener todos los usuarios (admin)
const getAllUsuarios = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('usuarios').select('*, areas(*), estados(*)');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener un usuario por ID (admin)
const getUsuarioById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('usuarios')
            .select('*, areas(*), estados(*)')
            .eq('id_usuario', id)
            .maybeSingle();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Usuario no encontrado' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar un usuario por ID (admin - puede cambiar rol, estado, área)
const updateUsuario = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { nombre, correo, rol, area_id, telefono, estado_id } = req.body;

        const { data, error } = await supabase
            .from('usuarios')
            .update({ nombre, correo, rol, area_id, telefono, estado_id })
            .eq('id_usuario', id)
            .select('*, areas(*), estados(*)')
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Usuario no encontrado' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Eliminar un usuario (admin)
const deleteUsuario = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Eliminar de la tabla usuarios (ON DELETE CASCADE eliminará datos relacionados)
        const { error } = await supabase
            .from('usuarios')
            .delete()
            .eq('id_usuario', id);

        if (error) throw error;
        res.json({ message: 'Usuario eliminado correctamente' });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getPerfil,
    updatePerfil,
    getAllUsuarios,
    getUsuarioById,
    updateUsuario,
    deleteUsuario
};
