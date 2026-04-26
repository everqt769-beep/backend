const { Router } = require('express');
const router = Router();
const { getAsignaciones, getAsignacionById, createAsignacion, getAsignacionesFuncionario, updateAsignacion, deleteAsignacion } = require('../controllers/asignaciones.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

router.use(requireAuth);

// Funcionario ve sus asignaciones
router.get('/mis-asignaciones', requireRole(['funcionario']), getAsignacionesFuncionario);

// Admin ve todas las asignaciones
router.get('/', requireRole(['admin']), getAsignaciones);
router.get('/:id', requireRole(['admin', 'funcionario']), getAsignacionById);

// Crear, actualizar, eliminar
router.post('/', requireRole(['admin', 'funcionario']), createAsignacion);
router.put('/:id', requireRole(['admin']), updateAsignacion);
router.delete('/:id', requireRole(['admin']), deleteAsignacion);

module.exports = router;
