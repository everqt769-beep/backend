const { Router } = require('express');
const router = Router();
const { createComentario, getComentariosByReporte, getComentarioById, updateComentario, deleteComentario } = require('../controllers/comentarios.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Leer comentarios requiere autenticación
router.use(requireAuth);

router.get('/reporte/:reporteId', getComentariosByReporte);
router.get('/:id', getComentarioById);
router.post('/', createComentario);
router.put('/:id', updateComentario);
router.delete('/:id', requireRole(['admin']), deleteComentario);

module.exports = router;
