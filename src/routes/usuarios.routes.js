const { Router } = require('express');
const router = Router();
const { getPerfil, updatePerfil, getAllUsuarios, getUsuarioById, updateUsuario, deleteUsuario } = require('../controllers/usuarios.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Todas las rutas requieren autenticación
router.use(requireAuth);

// Rutas del usuario autenticado
router.get('/perfil', getPerfil);
router.put('/perfil', updatePerfil);

// Rutas de administrador
router.get('/', requireRole(['admin']), getAllUsuarios);
router.get('/:id', requireRole(['admin']), getUsuarioById);
router.put('/:id', requireRole(['admin']), updateUsuario);
router.delete('/:id', requireRole(['admin']), deleteUsuario);

module.exports = router;
