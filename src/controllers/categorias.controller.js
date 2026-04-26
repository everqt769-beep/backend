const { supabase } = require('../config/supabase');

// Obtener todas las categorías (con relación a áreas)
const getCategorias = async (req, res, next) => {
    try {
        const { data, error } = await supabase.from('categorias').select('*, areas(*)');
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener categorías filtradas por área
const getCategoriasByArea = async (req, res, next) => {
    try {
        const { areaId } = req.params;
        const { data, error } = await supabase.from('categorias').select('*').eq('area_id', areaId);
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Obtener una categoría por ID
const getCategoriaById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('categorias')
            .select('*, areas(*)')
            .eq('id_categoria', id)
            .single();
        if (error) throw error;
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Crear una nueva categoría
const createCategoria = async (req, res, next) => {
    try {
        const { nombre, descripcion, prioridad_base, area_id } = req.body;

        if (!nombre) {
            return res.status(400).json({ error: 'El campo nombre es obligatorio' });
        }

        const { data, error } = await supabase
            .from('categorias')
            .insert([{ nombre, descripcion, prioridad_base, area_id }])
            .select('*, areas(*)')
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (err) {
        next(err);
    }
};

// Actualizar una categoría
const updateCategoria = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, prioridad_base, area_id } = req.body;

        const { data, error } = await supabase
            .from('categorias')
            .update({ nombre, descripcion, prioridad_base, area_id })
            .eq('id_categoria', id)
            .select('*, areas(*)')
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Categoría no encontrada' });
        res.json(data);
    } catch (err) {
        next(err);
    }
};

// Eliminar una categoría
const deleteCategoria = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { error } = await supabase
            .from('categorias')
            .delete()
            .eq('id_categoria', id);

        if (error) throw error;
        res.json({ message: 'Categoría eliminada correctamente' });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getCategorias,
    getCategoriasByArea,
    getCategoriaById,
    createCategoria,
    updateCategoria,
    deleteCategoria
};
