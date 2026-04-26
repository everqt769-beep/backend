const { Router } = require('express');
const router = Router();
const { getAreas, getAreaById, createArea, updateArea, deleteArea } = require('../controllers/areas.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Rutas públicas
router.get('/', getAreas);
router.get('/:id', getAreaById);

// Rutas protegidas (solo admin)
router.use(requireAuth);
router.post('/', requireRole(['admin']), createArea);
router.put('/:id', requireRole(['admin']), updateArea);
router.delete('/:id', requireRole(['admin']), deleteArea);

module.exports = router;
