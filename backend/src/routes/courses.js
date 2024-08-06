const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');
const LessonController = require('../app/controllers/LessonController');
const CommentController = require('../app/controllers/CommentController');
const ProjectController = require('../app/controllers/ProjectController');
const { authenticate, combinedAuthenticate } = require('../app/middleware/auth');
// const {getRandomCourses} = require('../app/controllers/CourseController')
// Courses
// get
router.get('/', authenticate, CourseController.getAllCourses);
router.post('/', authenticate, CourseController.createCourse);
router.get('/random', authenticate, CourseController.getRandomCourses);
router.post('/categories', authenticate, CourseController.getCoursesByCategory);
router.get('/top5', authenticate, CourseController.getTop5Courses);
router.get('/newest', authenticate, CourseController.getFiveNewestCourse);
router.post('/searchCourses', authenticate, CourseController.searchCourses);
router.post('/searchCoursesAndUsers', authenticate, CourseController.searchCoursesAndUsers);
router.post('/updateAllLessonLinks', authenticate, CourseController.updateAllLessonLinksController);
router.post('/add-field', authenticate, CourseController.addFieldToAllCourses);
router.get('/users/:id', authenticate, CourseController.getCourseByUserId)
router.get('/users/:id/public', authenticate, CourseController.getCoursePublicByUserId)
// router.post('/', authenticate, CourseController.createCourseWithLessons)
router.get('/:id', combinedAuthenticate, CourseController.getCourseById);
router.get('/:id/comments', authenticate, CommentController.showComments);
router.get('/:id/projects', authenticate, ProjectController.getAllProjects);
router.patch('/update-descriptions', authenticate, CourseController.updateCourseDescriptions);
router.patch('/:id', authenticate, CourseController.updateCourse);

router.delete('/:id', authenticate, CourseController.deleteCourse);
router.post('/batch', authenticate, CourseController.addCourses);
router.post('/addPrice', authenticate, CourseController.addPriceToAllCourses);
router.post('/changeId', authenticate, CourseController.changeTheInstructorId);
router.post('/updateLessonLinkByIndex', authenticate, CourseController.updateLessonLinkByIndex);
router.post('/updateLessonCount', authenticate, CourseController.updateLessonCountForCourses);
router.post('/:id/comments', authenticate, CommentController.createComment);
router.post('/:id/projects', authenticate, ProjectController.submitProject);
// Lessons
router.get('/:courseId/lessons', authenticate, LessonController.getAllLesson);
router.post('/:courseId/lessons', authenticate, LessonController.createLesson);
router.get('/:courseId/lessons/:lessonId', authenticate, LessonController.getLessonById);
router.get('/:courseId/combined-duration', authenticate, LessonController.getCombinedDuration);

//Resources
router.get('/:courseId/resources', authenticate, CourseController.getResourcesByCourseId)
router.post('/:courseId/resources', authenticate, CourseController.addResourceToCourse)
router.patch('/:courseId/resources/:resourceId', authenticate, CourseController.updateResourceInCourse)
router.delete('/:courseId/resources/:resourceId', authenticate, CourseController.deleteResourceFromCourse)

// watch project
router.get('/:courseId/projects/:userId', authenticate, ProjectController.getUserProject);
router.patch('/:courseId/lessons/:lessonId', authenticate, LessonController.updateLesson);
router.delete('/:courseId/lessons/:lessonId', authenticate, LessonController.deleteLesson);
router.delete('/:courseId/projects/:projectId', authenticate, ProjectController.removeProject);
router.post('/:id/comments/:commentId/replies', authenticate, CommentController.replyComment);

module.exports = router;