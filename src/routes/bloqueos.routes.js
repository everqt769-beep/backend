const { Router } = require('express');
const router = Router();
const {
    getUsuariosBloqueados,
    getHistorialBloqueos,
    bloquearUsuario,
    desbloquearUsuario,
    verificarBloqueo,
    getConfiguracion,
    updateConfiguracion,
    getEstadisticas
} = require('../controllers/bloqueos.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Todas las rutas requieren autenticación
router.use(requireAuth);

// Ruta para el usuario autenticado (cualquier rol)
router.get('/verificar', verificarBloqueo);

// Rutas de administrador
router.get('/config', requireRole(['admin']), getConfiguracion);
router.put('/config', requireRole(['admin']), updateConfiguracion);
router.get('/usuarios-bloqueados', requireRole(['admin']), getUsuariosBloqueados);
router.get('/estadisticas', requireRole(['admin']), getEstadisticas);
router.get('/historial/:usuario_id', requireRole(['admin']), getHistorialBloqueos);
router.post('/bloquear/:usuario_id', requireRole(['admin']), bloquearUsuario);
router.post('/desbloquear/:usuario_id', requireRole(['admin']), desbloquearUsuario);

module.exports = router;
