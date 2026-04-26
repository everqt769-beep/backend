const { Router } = require('express');
const router = Router();
const { getReportes, getReporteById, createReporte, updateEstadoReporte } = require('../controllers/reportes.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

router.get('/', getReportes);
router.get('/:id', getReporteById);

// Requiere autenticación
router.use(requireAuth);
router.post('/', createReporte);

// Requiere ser funcionario o admin
router.patch('/:id/estado', requireRole(['funcionario', 'admin']), updateEstadoReporte);

module.exports = router;
