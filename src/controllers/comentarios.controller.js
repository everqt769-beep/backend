const { supabase } = require('../config/supabase');

const createComentario = async (req, res, next) => {
    try {
        const { reporte_id, texto, tipo, padre_id } = req.body;
        const usuario_id = req.user.id;
        
        // Validar tipos según rol
        let finalTipo = 'publico';
        if (tipo && ['interno', 'respuesta_oficial'].includes(tipo) && ['funcionario', 'admin'].includes(req.user.rol)) {
            finalTipo = tipo;
        }

        const { data, error } = await supabase
            .from('comentarios')
            .insert([{
                reporte_id,
                usuario_id,
                texto,
                tipo: finalTipo,
                padre_id
            }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

const getComentariosByReporte = async (req, res, next) => {
    try {
        const { reporteId } = req.params;
        
        // En una app real, si el usuario es ciudadano, solo debería ver los públicos o respuesta oficial.
        // Pero eso lo maneja RLS en Supabase, así que aquí solo consultamos.
        
        const { data, error } = await supabase
            .from('comentarios')
            .select('*, usuarios(nombre, rol)')
            .eq('reporte_id', reporteId)
            .order('fecha', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    createComentario,
    getComentariosByReporte
};
