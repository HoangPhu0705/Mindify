const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');
const ReminderController = require('../app/controllers/ReminderController');
const { authenticate, authenticateJWT } = require('../app/middleware/auth')

router.get('/requests/', authenticateJWT, UserController.getRequests);
router.get('/searchUsers', authenticate, UserController.searchUsers);
router.get('/auth/:userId', authenticate, UserController.getUserNameAndAvatar);
router.get('/:userId', authenticate, UserController.getUserData);
router.get('/:userId/checkSavedCourse', authenticate, UserController.checkSavedCourse);

router.get('/:userId/savedCourses', authenticate, UserController.getSavedCourses);
router.get('/:userId/checkFollow', authenticate, UserController.checkIfUserFollows);
router.get('/:userId/watchedHistories', authenticate, UserController.getWatchedHistories);
router.get('/:userId/watchedHistories/time', authenticate, UserController.getWatchedTime);
router.get('/:userId/watchedHistories/:lessonId', authenticate, UserController.goToVideoWatched);
router.post('/updateUsers', authenticate, UserController.updateUsers);
router.post('/send-verification-email', authenticate, UserController.handleSendVerificationEmail);
router.post('/:userId/reminder', authenticate, ReminderController.addReminder);
router.post('/:userId/follow', authenticate, UserController.followUser);
router.post('/:userId/unfollow', authenticate, UserController.unfollowUser);
router.post('/:userId/saveCourse', authenticate, UserController.saveCourseForUser);
router.patch('/:userId/watchedHistories', authenticate, UserController.addToWatchedHistory);
router.post('/:userId/unsaveCourse', authenticate, UserController.unsaveCourseForUser);
router.post('/requestInstructor', authenticate, UserController.createInstructorSignUpRequest)
router.get('/requests/:requestId', authenticateJWT, UserController.getRequestDetails);
router.put('/requests/:requestId/approve', authenticateJWT, UserController.approveInstructorRequest);
router.put('/requests/:requestId/reject', authenticateJWT, UserController.rejectInstructorRequest);
router.delete('/requests/:requestId', authenticateJWT, UserController.deleteRequest);
router.delete('/:userId/reminder/:reminderId', authenticate, ReminderController.deleteReminder);
module.exports = router;