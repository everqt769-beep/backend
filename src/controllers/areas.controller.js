const { supabase } = require('../config/supabase');

const getAreas = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('areas').select('*');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const getAreaById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase.from('areas').select('*').eq('id_area', id).single();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getAreas,
    getAreaById
};
