const { Router } = require('express');
const router = Router();
const { getSeguimientoByReporte } = require('../controllers/seguimiento.controller');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);
router.get('/reporte/:reporteId', getSeguimientoByReporte);

module.exports = router;
