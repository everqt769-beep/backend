const { Router } = require('express');
const router = Router();
const { getReportes, getReporteById, createReporte, updateEstadoReporte, updateReporte, deleteReporte, analizarReporteConIA, getHistorialIA } = require('../controllers/reportes.controller');
const { requireAuth, requireRole, checkBloqueo } = require('../middlewares/authMiddleware');

// Rutas públicas (lectura)
router.get('/', getReportes);

// Ruta de admin (DEBE ir ANTES de /:id para que Express no confunda "historial-ia" con un UUID)
router.get('/historial-ia', requireAuth, requireRole(['admin']), getHistorialIA);

// Ruta pública por ID
router.get('/:id', getReporteById);

// Rutas autenticadas (con verificación de bloqueo para ciudadanos)
router.use(requireAuth);
router.post('/', checkBloqueo, createReporte);
router.put('/:id', checkBloqueo, updateReporte);

// Rutas de funcionario/admin
router.post('/:id/analizar', requireRole(['funcionario', 'admin']), analizarReporteConIA);
router.patch('/:id/estado', requireRole(['funcionario', 'admin']), updateEstadoReporte);
router.delete('/:id', requireRole(['admin']), deleteReporte);

module.exports = router;
