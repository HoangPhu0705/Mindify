const express = require('express');
const { assignAdminRoleController } = require('../app/controllers/huhu');

const router = express.Router();

router.post('/assign-admin', assignAdminRoleController);

module.exports = router;
