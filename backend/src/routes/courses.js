const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/course.controller');

router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.createCourse);
// router.patch('/:id', CourseController.updateCourse);
// router.delete('/:id', CourseController.deleteCourse);



module.exports = router;