const { Router } = require('express');
const router = Router();
const { getCategorias, getCategoriasByArea } = require('../controllers/categorias.controller');

router.get('/', getCategorias);
router.get('/area/:areaId', getCategoriasByArea);

module.exports = router;
