const express = require('express');
const router = express.Router();
const EnrollmentController = require('../app/controllers/EnrollmentController');

router.get('/checkEnrollment', EnrollmentController.checkEnrollment);
router.get('/userEnrollments', EnrollmentController.getUserEnrollments);
router.get('/downloadedLessons', EnrollmentController.getDownloadedLessons);
// router.post('/', EnrollmentController.createEnrollment);
router.post('/addLessonToEnrollment', EnrollmentController.addLessonToEnrollment);

module.exports = router;
