const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');

router.post('/:userId/saveCourse', UserController.saveCourseForUser);
router.post('/:userId/unsaveCourse', UserController.unsaveCourseForUser);
router.get('/:userId/savedCourses', UserController.getSavedCourses);
module.exports = router;