const { Router } = require('express');
const router = Router();
const { createComentario, getComentariosByReporte } = require('../controllers/comentarios.controller');
const { requireAuth } = require('../middlewares/authMiddleware');

router.get('/reporte/:reporteId', requireAuth, getComentariosByReporte); // RLS actuará aquí

router.use(requireAuth);
router.post('/', createComentario);

module.exports = router;
