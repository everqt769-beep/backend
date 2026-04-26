const { Router } = require('express');
const router = Router();
const { getSeguimientoByReporte, createSeguimiento, deleteSeguimiento } = require('../controllers/seguimiento.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/reporte/:reporteId', getSeguimientoByReporte);
router.post('/', requireRole(['admin', 'funcionario']), createSeguimiento);
router.delete('/:id', requireRole(['admin']), deleteSeguimiento);

module.exports = router;
