const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');
const LessonController = require('../app/controllers/LessonController');
// Courses
router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.createCourse);
router.get('/:id', CourseController.getCourseById);
router.patch('/:id', CourseController.updateCourse);
router.delete('/:id', CourseController.deleteCourse);
// Lessons
router.get('/:courseId/lessons', LessonController.getAllLesson);
router.post('/:courseId/lessons', LessonController.createLesson);
router.get('/:courseId/lessons/:lessonId', LessonController.getLessonById);
router.patch('/:courseId/lessons/:lessonId', LessonController.updateLesson);
router.delete('/:courseId/lessons/:lessonId', LessonController.deleteLesson);

// Route for top 5 courses
router.get('/top5', CourseController.getTop5Courses);
router.get('/random', CourseController.getRandomCourses);
module.exports = router;