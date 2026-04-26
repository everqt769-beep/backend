const { supabase, supabaseAdmin } = require('../config/supabase');

const getPerfil = async (req, res, next) => {
    try {
        const { id } = req.user;
        const { data, error } = await supabase.from('usuarios').select('*, areas(*), estados(*)').eq('id_usuario', id).single();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

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

const getAllUsuarios = async (req, res, next) => {
    try {
        // Asumiendo middleware de rol 'admin' anterior a esta llamada
        const { data, error } = await supabase.from('usuarios').select('*, areas(*), estados(*)');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getPerfil,
    updatePerfil,
    getAllUsuarios
};
