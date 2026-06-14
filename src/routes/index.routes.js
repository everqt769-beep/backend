const { Router } = require('express');
const router = Router();

const estadosRoutes = require('./estados.routes');
const areasRoutes = require('./areas.routes');
const categoriasRoutes = require('./categorias.routes');
const usuariosRoutes = require('./usuarios.routes');
const reportesRoutes = require('./reportes.routes');
const asignacionesRoutes = require('./asignaciones.routes');
const adjuntosRoutes = require('./adjuntos.routes');
const comentariosRoutes = require('./comentarios.routes');
const seguimientoRoutes = require('./seguimiento.routes');
const bloqueosRoutes = require('./bloqueos.routes');
const dashboardRoutes = require('./dashboard.routes');

router.use('/estados', estadosRoutes);
router.use('/areas', areasRoutes);
router.use('/categorias', categoriasRoutes);
router.use('/usuarios', usuariosRoutes);
router.use('/reportes', reportesRoutes);
router.use('/asignaciones', asignacionesRoutes);
router.use('/adjuntos', adjuntosRoutes);
router.use('/comentarios', comentariosRoutes);
router.use('/seguimiento', seguimientoRoutes);
router.use('/bloqueos', bloqueosRoutes);
router.use('/dashboard', dashboardRoutes);

module.exports = router;
