const express = require('express');
const router = express.Router();
const {getAllCourses} = require('../app/controllers/CourseController');

router.get('/', getAllCourses);
// router.post('/', CourseController.createCourse);
// router.patch('/:id', CourseController.updateCourse);
// router.delete('/:id', CourseController.deleteCourse);



module.exports = router;