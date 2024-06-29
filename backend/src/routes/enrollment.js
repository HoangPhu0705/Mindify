const express = require('express');
const router = express.Router();
const EnrollmentController = require('../app/controllers/EnrollmentController');

// router.get('/', EnrollmentController.getAllCourses);
router.post('/', EnrollmentController.createEnrollment);
// router.get('/random', CourseController.getRandomCourses);

module.exports = router;
