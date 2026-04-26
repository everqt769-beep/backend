const { Router } = require('express');
const router = Router();
const { createAdjunto, getAdjuntosByReporte, getAdjuntoById, updateEstadoAdjunto, deleteAdjunto } = require('../controllers/adjuntos.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Lectura pública de adjuntos por reporte
router.get('/reporte/:reporteId', getAdjuntosByReporte);
router.get('/:id', getAdjuntoById);

// Rutas autenticadas
router.use(requireAuth);
router.post('/', createAdjunto);
router.patch('/:id/moderacion', requireRole(['admin', 'funcionario']), updateEstadoAdjunto);
router.delete('/:id', requireRole(['admin']), deleteAdjunto);

module.exports = router;
