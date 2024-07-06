const express = require('express');
const router = express.Router();
const FolderController = require('../app/controllers/FolderController');

// router.get('/checkEnrollment', EnrollmentController.checkEnrollment);
router.get('/userFolders', FolderController.getFoldersofUser);
// router.get('/downloadedLessons', EnrollmentController.getDownloadedLessons);
router.post('/', FolderController.createFolder);
router.post('/addCourseToFolder', FolderController.addCourseToFolder);
router.get('/:folderId', FolderController.getFolderById);
router.get('/:folderId/courses', FolderController.getCoursesOfFolders);
router.delete('/:folderId', FolderController.deleteFolder);

module.exports = router;