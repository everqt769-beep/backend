const { supabase } = require('../config/supabase');

const createComentario = async (req, res, next) => {
    try {
        const { reporte_id, texto, tipo, padre_id } = req.body;
        const usuario_id = req.user.id;
        if (!reporte_id || !texto) {
            return res.status(400).json({ error: 'reporte_id y texto son obligatorios' });
        }
        let finalTipo = 'publico';
        if (tipo && ['interno', 'respuesta_oficial'].includes(tipo) && ['funcionario', 'admin'].includes(req.user.rol)) {
            finalTipo = tipo;
        }
        const { data, error } = await supabase.from('comentarios')
            .insert([{ reporte_id, usuario_id, texto, tipo: finalTipo, padre_id }])
            .select().single();
        if (error) throw error;
        res.status(201).json(data);
    } catch (err) { next(err); }
};

const getComentariosByReporte = async (req, res, next) => {
    try {
        const { reporteId } = req.params;
        const { data, error } = await supabase.from('comentarios')
            .select('*, usuarios(nombre, rol)')
            .eq('reporte_id', reporteId)
            .order('fecha', { ascending: true });
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const getComentarioById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase.from('comentarios')
            .select('*, usuarios(nombre, rol)')
            .eq('id_comentario', id).single();
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const updateComentario = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { texto } = req.body;
        const { data, error } = await supabase.from('comentarios')
            .update({ texto }).eq('id_comentario', id).select().single();
        if (error) throw error;
        res.json(data);
    } catch (err) { next(err); }
};

const deleteComentario = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase.from('comentarios').delete().eq('id_comentario', id);
        if (error) throw error;
        res.json({ message: 'Comentario eliminado correctamente' });
    } catch (err) { next(err); }
};

module.exports = { createComentario, getComentariosByReporte, getComentarioById, updateComentario, deleteComentario };
