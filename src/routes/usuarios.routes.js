const { Router } = require('express');
const router = Router();
const { getPerfil, updatePerfil, getAllUsuarios } = require('../controllers/usuarios.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Rutas autenticadas
router.use(requireAuth);

router.get('/perfil', getPerfil);
router.put('/perfil', updatePerfil);

// Rutas de administrador
router.get('/', requireRole(['admin']), getAllUsuarios);

module.exports = router;
