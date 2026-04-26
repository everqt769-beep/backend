const { supabase } = require('../config/supabase');

const getAsignaciones = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('asignaciones')
            .select('*, reportes(*, categorias(*)), estados(*)')
            .order('fecha_asignacion', { ascending: false });
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const getAsignacionById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('asignaciones').select('*, reportes(*), estados(*)')
            .eq('id_asignacion', id).single();
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const createAsignacion = async (req, res, next) => {
    try {
        const { reporte_id, funcionario_id } = req.body;
        if (!reporte_id || !funcionario_id) {
            return res.status(400).json({ error: 'reporte_id y funcionario_id son obligatorios' });
        }
        const { data: estado, error: estadoError } = await supabase
            .from('estados').select('id_estado')
            .eq('entidad', 'asignacion').eq('codigo', 'activa').single();
        if (estadoError) throw estadoError;

        const { data, error } = await supabase
            .from('asignaciones')
            .insert([{ reporte_id, funcionario_id, estado_id: estado.id_estado }])
            .select().single();
        if (error) throw error;

        const { data: estadoRep } = await supabase
            .from('estados').select('id_estado')
            .eq('entidad', 'reporte').eq('codigo', 'asignado').single();
        if (estadoRep) {
            await supabase.from('reportes').update({ estado_id: estadoRep.id_estado }).eq('id_reporte', reporte_id);
            await supabase.from('seguimiento').insert([{
                reporte_id, usuario_id: req.user.id, tipo_evento: 'asignacion',
                descripcion: 'Reporte asignado a un funcionario', estado_nuevo_id: estadoRep.id_estado
            }]);
        }
        res.status(201).json(data);
    } catch (err) { next(err); }
};

const getAsignacionesFuncionario = async (req, res, next) => {
    try {
        const { id } = req.user;
        const { data, error } = await supabase
            .from('asignaciones').select('*, reportes(*, categorias(*)), estados(*)')
            .eq('funcionario_id', id);
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const updateAsignacion = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { funcionario_id, estado_codigo } = req.body;
        const updates = {};
        if (funcionario_id) updates.funcionario_id = funcionario_id;
        if (estado_codigo) {
            const { data: estado, error: ee } = await supabase
                .from('estados').select('id_estado')
                .eq('entidad', 'asignacion').eq('codigo', estado_codigo).single();
            if (ee) throw ee;
            updates.estado_id = estado.id_estado;
        }
        const { data, error } = await supabase.from('asignaciones')
            .update(updates).eq('id_asignacion', id).select().single();
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const deleteAsignacion = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase.from('asignaciones').delete().eq('id_asignacion', id);
        if (error) throw error;
        res.json({ message: 'Asignación eliminada correctamente' });
    } catch (err) { next(err); }
};

module.exports = { getAsignaciones, getAsignacionById, createAsignacion, getAsignacionesFuncionario, updateAsignacion, deleteAsignacion };
