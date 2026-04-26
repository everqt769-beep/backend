const { Router } = require('express');
const router = Router();
const { getAreas, getAreaById } = require('../controllers/areas.controller');

router.get('/', getAreas);
router.get('/:id', getAreaById);

module.exports = router;
