const { Router } = require('express');
const router = Router();
const {
    getResumenDiario,
    getEstadisticasHistoricas,
    getReportesRechazados,
    generarReporte,
    getTendenciaMensual,
    getConteos
} = require('../controllers/dashboard.controller');
const { requireAuth, requireRole } = require('../middlewares/authMiddleware');

// Todas las rutas requieren autenticación y rol admin
router.use(requireAuth);
router.use(requireRole(['admin']));

// Tarjetas/conteos rápidos
router.get('/conteos', getConteos);

// Resumen del día
router.get('/resumen-diario', getResumenDiario);

// Estadísticas históricas (con filtros de fecha)
router.get('/estadisticas', getEstadisticasHistoricas);

// Reportes rechazados (falsos)
router.get('/rechazados', getReportesRechazados);

// Tendencia mensual (últimos 12 meses)
router.get('/tendencia-mensual', getTendenciaMensual);

// Generar reporte exportable
router.get('/generar-reporte', generarReporte);

module.exports = router;
