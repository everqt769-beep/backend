const { Router } = require('express');
const router = Router();
const { getEstados, getEstadosByEntidad } = require('../controllers/estados.controller');

router.get('/', getEstados);
router.get('/:entidad', getEstadosByEntidad);

module.exports = router;
