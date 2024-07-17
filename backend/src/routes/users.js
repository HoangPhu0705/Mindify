const express = require('express');
const router = express.Router();
const UserController = require('../app/controllers/UserController');

router.get('/requests/', UserController.getRequests);
router.get('/:userId', UserController.getUserData);
router.get('/auth/:userId', UserController.getUserNameAndAvatar);

router.get('/:userId/savedCourses', UserController.getSavedCourses);
router.get('/:userId/checkFollow', UserController.checkIfUserFollows);
router.get('/:userId/watchedHistories', UserController.getWatchedHistories);
router.get('/:userId/watchedHistories/time', UserController.getWatchedTime);
router.get('/:userId/watchedHistories/:lessonId', UserController.goToVideoWatched);
router.post('/updateUsers', UserController.updateUsers);
router.post('/:userId/follow', UserController.followUser);
router.post('/:userId/unfollow', UserController.unfollowUser);
router.post('/:userId/saveCourse', UserController.saveCourseForUser);
router.patch('/:userId/watchedHistories', UserController.addToWatchedHistory);
router.post('/:userId/unsaveCourse', UserController.unsaveCourseForUser);
router.post('/requestInstructor', UserController.createInstructorSignUpRequest)
router.get('/requests/:requestId', UserController.getRequestDetails);
router.put('/requests/:requestId/approve', UserController.approveInstructorRequest);
router.put('/requests/:requestId/reject', UserController.rejectInstructorRequest);

module.exports = router;