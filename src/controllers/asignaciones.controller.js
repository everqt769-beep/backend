const { supabase } = require('../config/supabase');

const createAsignacion = async (req, res, next) => {
    try {
        const { reporte_id, funcionario_id } = req.body;
        
        // Obtener estado activa
        const { data: estado, error: estadoError } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'asignacion')
            .eq('codigo', 'activa')
            .single();

        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('asignaciones')
            .insert([{
                reporte_id,
                funcionario_id,
                estado_id: estado.id_estado
            }])
            .select()
            .single();

        if (error) throw error;
        
        // Actualizar reporte a estado 'asignado'
        const { data: estadoRep } = await supabase
            .from('estados')
            .select('id_estado')
            .eq('entidad', 'reporte')
            .eq('codigo', 'asignado')
            .single();
            
        if (estadoRep) {
            await supabase.from('reportes').update({ estado_id: estadoRep.id_estado }).eq('id_reporte', reporte_id);
            
            await supabase.from('seguimiento').insert([{
                reporte_id,
                usuario_id: req.user.id,
                tipo_evento: 'asignacion',
                descripcion: 'Reporte asignado a un funcionario',
                estado_nuevo_id: estadoRep.id_estado
            }]);
        }

        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

const getAsignacionesFuncionario = async (req, res, next) => {
    try {
        const { id } = req.user;
        const { data, error } = await supabase
            .from('asignaciones')
            .select('*, reportes(*, categorias(*)), estados(*)')
            .eq('funcionario_id', id);

        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    createAsignacion,
    getAsignacionesFuncionario
};
