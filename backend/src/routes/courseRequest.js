const express = require('express');
const router = express.Router();
const CourseRequestController = require('../app/controllers/CourseRequestController');
const { authenticate, authenticateJWT } = require('../app/middleware/auth')

router.get('/', authenticateJWT, CourseRequestController.getRequests);
router.post('/:courseId', authenticate, CourseRequestController.sendRequest);
router.post('/:requestId/approve', authenticateJWT, CourseRequestController.approveRequest);
router.post('/:requestId/reject', authenticateJWT, CourseRequestController.rejectRequest);

module.exports = router;