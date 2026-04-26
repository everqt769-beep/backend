const { Router } = require('express');
const router = Router();
const { getEstados, getEstadosByEntidad, getEstadoById, createEstado, updateEstado, deleteEstado } = require('../controllers/estados.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Rutas públicas
router.get('/', getEstados);
router.get('/entidad/:entidad', getEstadosByEntidad);
router.get('/:id', getEstadoById);

// Rutas protegidas (solo admin)
router.use(requireAuth);
router.post('/', requireRole(['admin']), createEstado);
router.put('/:id', requireRole(['admin']), updateEstado);
router.delete('/:id', requireRole(['admin']), deleteEstado);

module.exports = router;
