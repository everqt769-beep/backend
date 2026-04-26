const { Router } = require('express');
const router = Router();
const { createAdjunto, getAdjuntosByReporte, updateEstadoAdjunto } = require('../controllers/adjuntos.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

router.get('/reporte/:reporteId', getAdjuntosByReporte);

router.use(requireAuth);
router.post('/', createAdjunto);
router.patch('/:id/moderacion', requireRole(['admin', 'funcionario']), updateEstadoAdjunto);

module.exports = router;
