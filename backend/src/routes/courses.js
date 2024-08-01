const express = require('express');
const router = express.Router();
const CourseController = require('../app/controllers/CourseController');
const LessonController = require('../app/controllers/LessonController');
const CommentController = require('../app/controllers/CommentController');
const ProjectController =  require('../app/controllers/ProjectController');
// const {getRandomCourses} = require('../app/controllers/CourseController')
// Courses
// get
router.get('/', CourseController.getAllCourses);
router.post('/', CourseController.createCourse);
router.get('/random', CourseController.getRandomCourses);
router.post('/categories', CourseController.getCoursesByCategory);
router.get('/top5', CourseController.getTop5Courses);
router.get('/newest', CourseController.getFiveNewestCourse);
router.post('/searchCourses', CourseController.searchCourses);
router.post('/searchOnChanged', CourseController.searchCoursesOnChanged);
router.post('/updateAllLessonLinks', CourseController.updateAllLessonLinksController);
router.post('/add-field', CourseController.addFieldToAllCourses);
router.get('/users/:id', CourseController.getCourseByUserId)
router.get('/users/:id/public', CourseController.getCoursePublicByUserId)
// router.post('/', CourseController.createCourseWithLessons)
router.get('/:id', CourseController.getCourseById);
router.get('/:id/comments', CommentController.showComments);
router.get('/:id/projects', ProjectController.getAllProjects);
router.patch('/update-descriptions', CourseController.updateCourseDescriptions);
router.patch('/:id', CourseController.updateCourse);

router.delete('/:id', CourseController.deleteCourse);
router.post('/batch', CourseController.addCourses);
router.post('/addPrice', CourseController.addPriceToAllCourses);
router.post('/changeId', CourseController.changeTheInstructorId);
router.post('/updateLessonLinkByIndex', CourseController.updateLessonLinkByIndex);
router.post('/updateLessonCount', CourseController.updateLessonCountForCourses);
router.post('/:id/comments', CommentController.createComment);
router.post('/:id/projects', ProjectController.submitProject);
// Lessons
router.get('/:courseId/lessons', LessonController.getAllLesson);
router.post('/:courseId/lessons', LessonController.createLesson);
router.get('/:courseId/lessons/:lessonId', LessonController.getLessonById);
router.get('/:courseId/combined-duration', LessonController.getCombinedDuration);

//Resources
router.get('/:courseId/resources', CourseController.getResourcesByCourseId)
router.post('/:courseId/resources', CourseController.addResourceToCourse)
router.patch('/:courseId/resources/:resourceId', CourseController.updateResourceInCourse)
router.delete('/:courseId/resources/:resourceId', CourseController.deleteResourceFromCourse)

// watch project
router.get('/:courseId/projects/:userId', ProjectController.getUserProject);
router.patch('/:courseId/lessons/:lessonId', LessonController.updateLesson);
router.delete('/:courseId/lessons/:lessonId', LessonController.deleteLesson);
router.delete('/:courseId/projects/:projectId', ProjectController.removeProject);
router.post('/:id/comments/:commentId/replies', CommentController.replyComment);

module.exports = router;