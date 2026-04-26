const { supabase } = require('../config/supabase');

const createAdjunto = async (req, res, next) => {
    try {
        const { reporte_id, tipo, url, nombre_archivo, tamano_bytes, descripcion } = req.body;
        const usuario_id = req.user.id;

        // Estado por defecto: pendiente de moderación
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'adjunto')
            .eq('codigo', 'pendiente_mod')
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('adjuntos')
            .insert([{
                reporte_id,
                usuario_id,
                tipo,
                url,
                nombre_archivo,
                tamano_bytes,
                descripcion,
                estado_moderacion_id: estado.id_estado
            }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

const getAdjuntosByReporte = async (req, res, next) => {
    try {
        const { reporteId } = req.params;
        const { data, error } = await supabase
            .from('adjuntos')
            .select('*, estados(*)')
            .eq('reporte_id', reporteId);

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const updateEstadoAdjunto = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { estado_codigo } = req.body; // ej. 'aprobado_mod', 'rechazado_mod'

        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'adjunto')
            .eq('codigo', estado_codigo)
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('adjuntos')
            .update({ estado_moderacion_id: estado.id_estado })
            .eq('id_adjunto', id)
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    createAdjunto,
    getAdjuntosByReporte,
    updateEstadoAdjunto
};
