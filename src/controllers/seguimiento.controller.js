const { supabase } = require('../config/supabase');

const getSeguimientoByReporte = async (req, res, next) => {
    try {
        const { reporteId } = req.params;
        const { data, error } = await supabase.from('seguimiento')
            .select('*, estados(*), usuarios(nombre)')
            .eq('reporte_id', reporteId)
            .order('fecha', { ascending: true });
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const createSeguimiento = async (req, res, next) => {
    try {
        const { reporte_id, tipo_evento, descripcion, estado_nuevo_id } = req.body;
        const usuario_id = req.user.id;
        if (!reporte_id || !tipo_evento) {
            return res.status(400).json({ error: 'reporte_id y tipo_evento son obligatorios' });
        }
        const { data, error } = await supabase.from('seguimiento')
            .insert([{ reporte_id, usuario_id, tipo_evento, descripcion, estado_nuevo_id }])
            .select().single();
        if (error) throw error;
        res.status(201).json(data);
    } catch (err) { next(err); }
};

const deleteSeguimiento = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase.from('seguimiento').delete().eq('id_seguimiento', id);
        if (error) throw error;
        res.json({ message: 'Registro de seguimiento eliminado correctamente' });
    } catch (err) { next(err); }
};

module.exports = { getSeguimientoByReporte, createSeguimiento, deleteSeguimiento };
