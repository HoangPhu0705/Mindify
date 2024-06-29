const express = require('express');
const router = express.Router();
const EnrollmentController = require('../app/controllers/EnrollmentController');

router.get('/checkEnrollment', EnrollmentController.checkEnrollment);
router.get('/userEnrollments', EnrollmentController.getUserEnrollments);
router.post('/', EnrollmentController.createEnrollment);

module.exports = router;
