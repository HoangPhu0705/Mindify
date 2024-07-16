const express = require('express');
const { loginController } = require('../app/controllers/AdminController');

const router = express.Router();

router.post('/admin-login', loginController);

module.exports = router;
