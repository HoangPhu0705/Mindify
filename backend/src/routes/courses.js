const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');
const LessonController = require('../app/controllers/LessonController');
const CommentController = require('../app/controllers/CommentController');
// const {getRandomCourses} = require('../app/controllers/CourseController')
// Courses
// get
router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.createCourse);
router.get('/random', CourseController.getRandomCourses);
router.post('/categories', CourseController.getCoursesByCategory);
router.get('/top5', CourseController.getTop5Courses);
router.get('/newest', CourseController.getFiveNewestCourse);
router.post('/updateAllLessonLinks', CourseController.updateAllLessonLinksController);
router.get('/users/:id', CourseController.getCourseByUserId)
// router.post('/', CourseController.createCourseWithLessons)
router.get('/:id', CourseController.getCourseById);
router.get('/:id/comments', CommentController.showComments);
router.patch('/update-descriptions', CourseController.updateCourseDescriptions);
router.patch('/:id', CourseController.updateCourse);

router.delete('/:id', CourseController.deleteCourse);
router.post('/batch', CourseController.addCourses);
router.post('/addPrice', CourseController.addPriceToAllCourses);
router.post('/changeId', CourseController.changeTheInstructorId);
router.post('/updateLessonLinkByIndex', CourseController.updateLessonLinkByIndex);
router.post('/updateLessonCount', CourseController.updateLessonCountForCourses);
router.post('/:id/comments', CommentController.createComment);
// Lessons
router.get('/:courseId/lessons', LessonController.getAllLesson);
router.post('/:courseId/lessons', LessonController.createLesson);
router.get('/:courseId/lessons/:lessonId', LessonController.getLessonById);
router.patch('/:courseId/lessons/:lessonId', LessonController.updateLesson);
router.delete('/:courseId/lessons/:lessonId', LessonController.deleteLesson);

router.post('/:id/comments/:commentId/replies', CommentController.replyComment);

module.exports = router;