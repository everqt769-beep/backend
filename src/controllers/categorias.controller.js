const { supabase } = require('../config/supabase');

const getCategorias = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('categorias').select('*, areas(*)');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const getCategoriasByArea = async (req, res, next) => {
    try {
        const { areaId } = req.params;
        const { data, error } = await supabase.from('categorias').select('*').eq('area_id', areaId);
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getCategorias,
    getCategoriasByArea
};
