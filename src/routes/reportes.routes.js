const { Router } = require('express');
const router = Router();
const { getReportes, getReporteById, createReporte, updateEstadoReporte, updateReporte, deleteReporte, analizarReporteConIA } = require('../controllers/reportes.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Rutas públicas (lectura)
router.get('/', getReportes);
router.get('/:id', getReporteById);

// Rutas autenticadas
router.use(requireAuth);
router.post('/', createReporte);
router.put('/:id', updateReporte);

// Rutas de funcionario/admin
router.post('/:id/analizar', requireRole(['funcionario', 'admin']), analizarReporteConIA);
router.patch('/:id/estado', requireRole(['funcionario', 'admin']), updateEstadoReporte);
router.delete('/:id', requireRole(['admin']), deleteReporte);

module.exports = router;
