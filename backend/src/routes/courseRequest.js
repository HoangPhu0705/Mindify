const express = require('express');
const router = express.Router();
const CourseRequestController = require('../app/controllers/CourseRequestController');

router.get('/', CourseRequestController.getRequests);
router.post('/:courseId', CourseRequestController.sendRequest);
router.post('/:requestId/approve', CourseRequestController.approveRequest);
router.post('/:requestId/reject', CourseRequestController.rejectRequest);

module.exports = router;