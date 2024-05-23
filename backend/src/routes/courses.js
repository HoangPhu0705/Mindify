const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');

router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.addCourse);
router.patch('/:id', CourseController.updateCourse);
router.delete('/:id', CourseController.deleteCourse);



module.exports = router;