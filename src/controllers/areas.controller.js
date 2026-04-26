const { supabase } = require('../config/supabase');

// Obtener todas las áreas
const getAreas = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('areas').select('*');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener un área por ID
const getAreaById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('areas')
            .select('*')
            .eq('id_area', id)
            .single();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Crear una nueva área
const createArea = async (req, res, next) => {
    try {
        const { nombre, descripcion, telefono, email } = req.body;

        if (!nombre) {
            return res.status(400).json({ error: 'El campo nombre es obligatorio' });
        }

        const { data, error } = await supabase
            .from('areas')
            .insert([{ nombre, descripcion, telefono, email }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar un área
const updateArea = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, telefono, email } = req.body;

        const { data, error } = await supabase
            .from('areas')
            .update({ nombre, descripcion, telefono, email })
            .eq('id_area', id)
            .select()
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Área no encontrada' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Eliminar un área
const deleteArea = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('areas')
            .delete()
            .eq('id_area', id);

        if (error) throw error;
        res.json({ message: 'Área eliminada correctamente' });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getAreas,
    getAreaById,
    createArea,
    updateArea,
    deleteArea
};
