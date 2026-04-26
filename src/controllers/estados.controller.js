const { supabase } = require('../config/supabase');

const getEstados = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('estados').select('*');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const getEstadosByEntidad = async (req, res, next) => {
    try {
        const { entidad } = req.params;
        const { data, error } = await supabase.from('estados').select('*').eq('entidad', entidad);
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getEstados,
    getEstadosByEntidad
};
