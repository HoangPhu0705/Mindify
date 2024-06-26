const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');

router.get('/:userId/savedCourses', UserController.getSavedCourses);
router.post('/:userId/saveCourse', UserController.saveCourseForUser);
router.post('/:userId/unsaveCourse', UserController.unsaveCourseForUser);
router.post('/requestInstructor', UserController.createInstructorSignUpRequest)
router.put('/requests/:requestId/approve', UserController.approveInstructorRequest);
router.get('/requests/unapproved', UserController.getUnapprovedRequests);
router.get('/requests/:requestId', UserController.getRequestDetails);
module.exports = router;