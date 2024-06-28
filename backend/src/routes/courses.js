const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');
const LessonController = require('../app/controllers/LessonController');
// const {getRandomCourses} = require('../app/controllers/CourseController')
// Courses
router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.createCourse);
router.get('/random', CourseController.getRandomCourses);
// router.post('/', CourseController.createCourseWithLessons)
router.get('/:id', CourseController.getCourseById);
router.get('/top5', CourseController.getTop5Courses);
router.patch('/:id', CourseController.updateCourse);
router.delete('/:id', CourseController.deleteCourse);
// router.get('/top5', CourseController.);
router.post('/batch', CourseController.addCourses);
router.post('/addPrice', CourseController.addPriceToAllCourses);

// Lessons
router.get('/:courseId/lessons', LessonController.getAllLesson);
router.post('/:courseId/lessons', LessonController.createLesson);
router.get('/:courseId/lessons/:lessonId', LessonController.getLessonById);
router.patch('/:courseId/lessons/:lessonId', LessonController.updateLesson);
router.delete('/:courseId/lessons/:lessonId', LessonController.deleteLesson);


module.exports = router;