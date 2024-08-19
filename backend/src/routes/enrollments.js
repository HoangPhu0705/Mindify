const express = require('express');
const router = express.Router();
const EnrollmentController = require('../app/controllers/EnrollmentController');
const NoteController = require('../app/controllers/NoteController');

router.get('/checkEnrollment', EnrollmentController.checkEnrollment);
router.get('/userEnrollments', EnrollmentController.getUserEnrollments);
router.get('/downloadedLessons', EnrollmentController.getDownloadedLessons);
router.get('/studentsOfMonth/:userId', EnrollmentController.getStudentsOfMonth);
router.get('/revenueOfMonth/:userId', EnrollmentController.getRevenueOfMonth);

router.get('/:enrollmentId/notes', NoteController.getAllNotesOfEnrollmentController);
router.get('/:enrollmentId/progress', EnrollmentController.getProgressOfEnrollment);
router.get('/:courseId/students', EnrollmentController.showStudentsOfCourse);
router.post('/:enrollmentId/notes', NoteController.addNoteController);
router.post('/:enrollmentId/progress', EnrollmentController.addProgressToEnrollment);
router.post('/addLessonToEnrollment', EnrollmentController.addLessonToEnrollment);
router.delete('/:enrollmentId/:noteId', NoteController.deleteNoteController);
router.put('/:enrollmentId/:noteId', NoteController.updateNoteController);

module.exports = router;
