const { supabase } = require('../config/supabase');

const getReportes = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('reportes')
            .select(`
                *,
                usuarios(nombre, correo),
                categorias(nombre, areas(nombre)),
                estados(nombre, color)
            `)
            .order('fecha_creacion', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const getReporteById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('reportes')
            .select(`
                *,
                usuarios(nombre, correo),
                categorias(nombre, areas(*)),
                estados(*),
                adjuntos(*),
                comentarios(*, usuarios(nombre, rol)),
                seguimiento(*, estados(*), usuarios(nombre))
            `)
            .eq('id_reporte', id)
            .single();

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

const createReporte = async (req, res, next) => {
    try {
        const { categoria_id, descripcion, latitud, longitud, direccion } = req.body;
        const usuario_id = req.user.id;

        // Obtener id del estado 'pendiente' para reporte
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'reporte')
            .eq('codigo', 'pendiente')
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('reportes')
            .insert([{
                usuario_id,
                categoria_id,
                descripcion,
                latitud,
                longitud,
                direccion,
                estado_id: estado.id_estado
            }])
            .select()
            .single();

        if (error) throw error;

        // Registrar en seguimiento
        await supabase.from('seguimiento').insert([{
            reporte_id: data.id_reporte,
            usuario_id,
            tipo_evento: 'creacion',
            descripcion: 'Reporte creado por el ciudadano',
            estado_nuevo_id: estado.id_estado
        }]);

        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

const updateEstadoReporte = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { estado_codigo, descripcion_seguimiento } = req.body;
        const usuario_id = req.user.id;

        // Obtener ID del nuevo estado
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'reporte')
            .eq('codigo', estado_codigo)
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('reportes')
            .update({ estado_id: estado.id_estado })
            .eq('id_reporte', id)
            .select()
            .single();

        if (error) throw error;

        // Registrar en seguimiento
        await supabase.from('seguimiento').insert([{
            reporte_id: id,
            usuario_id,
            tipo_evento: 'cambio_estado',
            descripcion: descripcion_seguimiento || `Estado cambiado a ${estado_codigo}`,
            estado_nuevo_id: estado.id_estado
        }]);

        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getReportes,
    getReporteById,
    createReporte,
    updateEstadoReporte
};
