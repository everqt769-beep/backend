const { Router } = require('express');
const router = Router();
const { getCategorias, getCategoriasByArea, getCategoriaById, createCategoria, updateCategoria, deleteCategoria } = require('../controllers/categorias.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Rutas públicas
router.get('/', getCategorias);
router.get('/area/:areaId', getCategoriasByArea);
router.get('/:id', getCategoriaById);

// Rutas protegidas (solo admin)
router.use(requireAuth);
router.post('/', requireRole(['admin']), createCategoria);
router.put('/:id', requireRole(['admin']), updateCategoria);
router.delete('/:id', requireRole(['admin']), deleteCategoria);

module.exports = router;
