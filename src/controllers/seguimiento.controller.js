const { supabase } = require('../config/supabase');

const getSeguimientoByReporte = async (req, res, next) => {
    try {
        const { reporteId } = req.params;
        const { data, error } = await supabase
            .from('seguimiento')
            .select('*, estados(*), usuarios(nombre)')
            .eq('reporte_id', reporteId)
            .order('fecha', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getSeguimientoByReporte
};
