const express = require('express');
const AdminController = require('../app/controllers/AdminController');

const router = express.Router();

router.post('/admin-login', AdminController.loginController);
router.get('/admin-logout', AdminController.logOut);
router.get('/users-management', AdminController.showAllUsers);
router.get('/courses-management', AdminController.showAllCourses);

module.exports = router;
