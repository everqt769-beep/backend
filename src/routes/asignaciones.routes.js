const { Router } = require('express');
const router = Router();
const { createAsignacion, getAsignacionesFuncionario } = require('../controllers/asignaciones.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/mis-asignaciones', requireRole(['funcionario']), getAsignacionesFuncionario);
router.post('/', requireRole(['admin', 'funcionario']), createAsignacion);

module.exports = router;
