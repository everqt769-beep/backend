const { supabase } = require('../config/supabase');

// Obtener todos los estados
const getEstados = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('estados').select('*');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener estados filtrados por entidad
const getEstadosByEntidad = async (req, res, next) => {
    try {
        const { entidad } = req.params;
        const { data, error } = await supabase.from('estados').select('*').eq('entidad', entidad);
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener un estado por ID
const getEstadoById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('estados')
            .select('*')
            .eq('id_estado', id)
            .single();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Crear un nuevo estado
const createEstado = async (req, res, next) => {
    try {
        const { entidad, codigo, nombre, color, descripcion } = req.body;

        if (!entidad || !codigo || !nombre) {
            return res.status(400).json({ error: 'Los campos entidad, codigo y nombre son obligatorios' });
        }

        const { data, error } = await supabase
            .from('estados')
            .insert([{ entidad, codigo, nombre, color, descripcion }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar un estado
const updateEstado = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { entidad, codigo, nombre, color, descripcion } = req.body;

        const { data, error } = await supabase
            .from('estados')
            .update({ entidad, codigo, nombre, color, descripcion })
            .eq('id_estado', id)
            .select()
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Estado no encontrado' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Eliminar un estado
const deleteEstado = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('estados')
            .delete()
            .eq('id_estado', id);

        if (error) throw error;
        res.json({ message: 'Estado eliminado correctamente' });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getEstados,
    getEstadosByEntidad,
    getEstadoById,
    createEstado,
    updateEstado,
    deleteEstado
};
