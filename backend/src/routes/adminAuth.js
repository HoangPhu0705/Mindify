const express = require('express');
const AdminController = require('../app/controllers/AdminController');

const router = express.Router();

router.post('/admin-login', AdminController.loginController);
router.get('/admin-logout', AdminController.logOut);

module.exports = router;
