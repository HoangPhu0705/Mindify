const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');
const ReminderController = require('../app/controllers/ReminderController');

router.get('/requests/', UserController.getRequests);
router.get('/searchUsers', UserController.searchUsers);
router.get('/auth/:userId', UserController.getUserNameAndAvatar);
router.get('/:userId', UserController.getUserData);
router.get('/:userId/checkSavedCourse', UserController.checkSavedCourse);

router.get('/:userId/savedCourses', UserController.getSavedCourses);
router.get('/:userId/checkFollow', UserController.checkIfUserFollows);
router.get('/:userId/watchedHistories', UserController.getWatchedHistories);
router.get('/:userId/watchedHistories/time', UserController.getWatchedTime);
router.get('/:userId/watchedHistories/:lessonId', UserController.goToVideoWatched);
router.post('/updateUsers', UserController.updateUsers);
router.post('/:userId/reminder', ReminderController.addReminder);
router.post('/:userId/follow', UserController.followUser);
router.post('/:userId/unfollow', UserController.unfollowUser);
router.post('/:userId/saveCourse', UserController.saveCourseForUser);
router.patch('/:userId/watchedHistories', UserController.addToWatchedHistory);
router.post('/:userId/unsaveCourse', UserController.unsaveCourseForUser);
router.post('/requestInstructor', UserController.createInstructorSignUpRequest)
router.get('/requests/:requestId', UserController.getRequestDetails);
router.put('/requests/:requestId/approve', UserController.approveInstructorRequest);
router.put('/requests/:requestId/reject', UserController.rejectInstructorRequest);
router.delete('/:userId/reminder/:reminderId', ReminderController.deleteReminder);
module.exports = router;