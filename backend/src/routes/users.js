const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');

router.post('/:userId/saveCourse', UserController.saveCourseForUser);

module.exports = router;