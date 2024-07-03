const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');


router.get('/requests/', UserController.getRequests);
router.get('/:userId', UserController.getUserData);
router.get('/:userId/savedCourses', UserController.getSavedCourses);
router.post('/:userId/saveCourse', UserController.saveCourseForUser);
router.post('/:userId/unsaveCourse', UserController.unsaveCourseForUser);
router.post('/requestInstructor', UserController.createInstructorSignUpRequest)
router.get('/requests/:requestId', UserController.getRequestDetails);
router.put('/requests/:requestId/approve', UserController.approveInstructorRequest);
router.put('/requests/:requestId/reject', UserController.rejectInstructorRequest);
module.exports = router;